//
//  PlanOnboardingView.swift
//  KinesteXSDKDemoSwift
//
//  Created on 2/24/26.
//

import SwiftUI
import KinesteXAIKit

struct PlanOnboardingView: View {
    let kinestex = KinesteXAIKit(
        apiKey: "your_api_key",
        companyName: "your_company_name",
        userId: "your_user_id"
    )

    let planAPI = PlanAPIService(
        apiKey: "your_api_key",
        userId: "your_user_id"
    )

    var user = UserDetails(age: 20, height: 170, weight: 70, gender: .Male, lifestyle: .Active)

    // MARK: - State
    @State private var showOnboarding = false
    @State private var isLoading = true

    // Plan data read from UserDefaults on appear
    @State private var planId: String = ""
    @State private var planType: String = ""

    // Fetched plan (new Client API)
    @State private var clientPlan: ClientPlan?
    @State private var personalPlan: PersonalPlan?
    @State private var isFetchingPlan = false
    @State private var fetchError: String?
    @State private var expandedWeeks: [Int: Bool] = [:]

    // Current workout detail (fetched via SDK)
    @State private var currentWorkoutModel: WorkoutModel?

    @State private var isPlanDetailExpanded = false

    // Custom workout launch state
    @State private var showCustomWorkout = false
    @State private var workoutAction: [String: Any]? = nil
    @State private var customWorkoutLoading = true

    // Standalone workout launch state
    @State private var selectedWorkoutName: String? = nil

    // Challenge launch state
    @State private var selectedChallengeName: String? = nil

    var body: some View {
        if showOnboarding {
            onboardingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if showCustomWorkout, let workout = currentWorkoutModel {
            customWorkoutView(workout: workout)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let workoutName = selectedWorkoutName {
            standaloneWorkoutView(name: workoutName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let challengeName = selectedChallengeName {
            challengeView(name: challengeName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            mainView
        }
    }

    // MARK: - Onboarding WebView
    @ViewBuilder
    var onboardingView: some View {
        kinestex.createCustomComponentView(
            route: "plan-onboarding",
            user: user,
            style: nil,
            isLoading: $isLoading,
            customParams: ["style": "dark"],
            onMessageReceived: { message in
                handleMessage(message)
            }
        )
    }

    // MARK: - Custom Workout View
    @ViewBuilder
    func customWorkoutView(workout: WorkoutModel) -> some View {
        let exercises = workout.sequence.map { ex in
            WorkoutSequenceExercise(
                exerciseId: ex.id,
                reps: ex.workoutReps,
                duration: ex.workoutCountdown,
                includeRestPeriod: (ex.restDuration ?? 0) > 0,
                restDuration: ex.restDuration ?? 0
            )
        }

        ZStack {
            kinestex.createCustomWorkoutView(
                exercises: exercises,
                user: user,
                style: nil,
                isLoading: $isLoading,
                workoutAction: $workoutAction,
                customParams: ["style": "dark", "planId": planId, "planType": planType],
                onMessageReceived: { message in
                    switch message {
                    case .custom_type(let value):
                        guard let type = value["type"] as? String else { return }
                        if type == "all_resources_loaded" {
                            withAnimation {
                                customWorkoutLoading = false
                            }
                            workoutAction = ["workout_activity_action": "start"]
                        }
                    case .exit_kinestex(_):
                        showCustomWorkout = false
                        workoutAction = nil
                        customWorkoutLoading = true
                    case .workout_completed(_):
                        showCustomWorkout = false
                        workoutAction = nil
                        customWorkoutLoading = true
                    case .error_occurred(let data):
                        print("[CustomWorkout] Error: \(data)")
                    default:
                        break
                    }
                }
            )

            if customWorkoutLoading {
                Color.black
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Loading workout...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
    }

    // MARK: - Standalone Workout View
    @ViewBuilder
    func standaloneWorkoutView(name: String) -> some View {
        kinestex.createWorkoutView(
            workout: name,
            user: user,
            style: nil,
            isLoading: $isLoading,
            customParams: ["style": "dark"],
            onMessageReceived: { message in
                switch message {
                case .exit_kinestex(_):
                    selectedWorkoutName = nil
                case .workout_completed(_):
                    selectedWorkoutName = nil
                case .error_occurred(let data):
                    print("[Workout] Error: \(data)")
                default:
                    break
                }
            }
        )
    }

    // MARK: - Challenge View
    @ViewBuilder
    func challengeView(name: String) -> some View {
        kinestex.createChallengeView(
            exercise: name,
            duration: 60,
            user: user,
            style: nil,
            isLoading: $isLoading,
            customParams: ["style": "dark"],
            onMessageReceived: { message in
                switch message {
                case .exit_kinestex(_):
                    selectedChallengeName = nil
                case .workout_completed(_):
                    selectedChallengeName = nil
                case .error_occurred(let data):
                    print("[Challenge] Error: \(data)")
                default:
                    break
                }
            }
        )
    }

    // MARK: - Main View
    @ViewBuilder
    var mainView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Header
                    VStack(spacing: 4) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 36))
                            .foregroundColor(.green)

                        Text("Plan Onboarding")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Complete a fitness questionnaire to get a personalized workout plan")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)

                    // Always show plan ID status
                    planIdDisplay

                    // Stored Plan Info card (when we have a plan)
                    if !planId.isEmpty {
                        storedPlanCard
                    }

                    // Current Workout Routine
                    if let workoutModel = currentWorkoutModel {
                        WorkoutRoutineView(workout: workoutModel) {
                            showCustomWorkout = true
                        }
                    } else if currentWorkout != nil {
                        ProgressView("Loading workout...")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(.vertical, 4)
                    }

                    // Fetched Plan Detail (collapsible)
                    if let plan = clientPlan {
                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation { isPlanDetailExpanded.toggle() }
                            }) {
                                HStack {
                                    Text("Plan Details")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: isPlanDetailExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .contentShape(Rectangle())
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)

                            if isPlanDetailExpanded {
                                ClientPlanDetailView(
                                    plan: plan,
                                    personalPlan: personalPlan,
                                    expandedWeeks: $expandedWeeks
                                )
                                .padding(.top, 8)
                            }
                        }
                    } else if isFetchingPlan {
                        ProgressView("Loading plan details...")
                            .foregroundColor(.white)
                            .padding()
                    } else if let error = fetchError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }

                    // Featured Workouts
                    featuredWorkoutsSection

                    // Challenges
                    challengesSection

                    Spacer(minLength: 16)

                    // Launch Button
                    Button(action: {
                        showOnboarding = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                            Text(planId.isEmpty ? "Start Plan Onboarding" : "Retake Onboarding")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .bold()
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.cornerRadius(10))
                        .padding(.horizontal)
                    }

                    // Reset Button (only shown when plan exists)
                    if !planId.isEmpty {
                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "plan_onboarding_plan_id")
                            UserDefaults.standard.removeObject(forKey: "plan_onboarding_plan_type")
                            planId = ""
                            planType = ""
                            clientPlan = nil
                            personalPlan = nil
                            currentWorkoutModel = nil
                            fetchError = nil
                        }) {
                            Text("Clear Stored Plan")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.black)
            .navigationBarHidden(true)
            .onAppear {
                syncFromStorage()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Current Workout (from either plan type)
    private var currentWorkout: ClientCurrentWorkout? {
        if let cw = personalPlan?.current_workout { return cw }
        if let cw = clientPlan?.currentWorkout { return cw }
        return nil
    }

    // MARK: - Plan ID Display (always visible)
    @ViewBuilder
    var planIdDisplay: some View {
        VStack(spacing: 3) {
            Text("Plan ID")
                .font(.caption2)
                .foregroundColor(.gray)
            Text(planId.isEmpty ? "No plan ID yet" : planId)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(planId.isEmpty ? .gray.opacity(0.5) : .white)
                .textSelection(.enabled)
            if !planType.isEmpty {
                Text("Type: \(planType)")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    // MARK: - Stored Plan Card
    @ViewBuilder
    var storedPlanCard: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Assigned Plan")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    HStack(spacing: 6) {
                        Text(planType == "personalized" ? "AI Personalized" : "Goal Based")
                            .font(.caption2)
                            .foregroundColor(planType == "personalized" ? .purple : .blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                (planType == "personalized" ? Color.purple : Color.blue)
                                    .opacity(0.2)
                                    .cornerRadius(4)
                            )
                    }
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.body)
            }

            if clientPlan == nil && !isFetchingPlan {
                Button(action: { fetchPlan() }) {
                    Text("Load Plan Details")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    // MARK: - Featured Workouts
    @ViewBuilder
    var featuredWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workouts")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    WorkoutCard(
                        title: "Fitness Lite",
                        imageURL: "https://cdn.kinestex.com/uploads%2F9zE1kzOzpU5d5dAJrPOY_1733253066941.webp",
                        calories: 130,
                        minutes: 11,
                        difficulty: "Medium"
                    ) {
                        selectedWorkoutName = "Fitness Lite"
                    }

                    WorkoutCard(
                        title: "Circuit Training",
                        imageURL: "https://cdn.kinestex.com/uploads%2F8wpaODs7yRMXP1WhX5Gv_1733253066934.webp",
                        calories: 200,
                        minutes: 30,
                        difficulty: "Hard"
                    ) {
                        selectedWorkoutName = "Circuit Training"
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Challenges
    @ViewBuilder
    var challengesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Challenges")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ChallengeCard(
                        title: "Squats",
                        calories: 30,
                        duration: "1 minute"
                    ) {
                        selectedChallengeName = "jz73VFlUyZ9nyd64OjRb"
                    }

                    ChallengeCard(
                        title: "Jumping Jack",
                        calories: 20,
                        duration: "1 minute"
                    ) {
                        selectedChallengeName = "ZVMeLsaXQ9Tzr5JYXg29"
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Message Handling
    private func handleMessage(_ message: KinestexMessage) {
        print("[PlanOnboarding] \(message)")

        switch message {
        case .exit_kinestex(_):
            showOnboarding = false

        case .custom_type(let value):
            guard let type = value["type"] as? String else { return }

            if type == "plan_onboarding_plan_created",
               let data = value["data"] as? [String: Any] {
                let id = data["plan_id"] as? String ?? ""
                let pt = data["plan_type"] as? String ?? ""
                UserDefaults.standard.set(id, forKey: "plan_onboarding_plan_id")
                UserDefaults.standard.set(pt, forKey: "plan_onboarding_plan_type")
                print("[PlanOnboarding] Stored plan_id: \(id), plan_type: \(pt)")
            }

        case .error_occurred(let value):
            print("[PlanOnboarding] error: \(value)")

        default:
            break
        }
    }

    // MARK: - Sync from UserDefaults
    private func syncFromStorage() {
        let storedId = UserDefaults.standard.string(forKey: "plan_onboarding_plan_id") ?? ""
        let storedType = UserDefaults.standard.string(forKey: "plan_onboarding_plan_type") ?? ""

        print("[PlanOnboarding] syncFromStorage - plan_id: '\(storedId)', plan_type: '\(storedType)'")

        planId = storedId
        planType = storedType

        if !storedId.isEmpty && clientPlan == nil {
            print("[PlanOnboarding] Fetching plan for id: \(storedId)")
            fetchPlan(id: storedId)
        }
    }

    // MARK: - Fetch Plan
    private func fetchPlan(id: String? = nil) {
        let targetId = id ?? planId
        guard !targetId.isEmpty else { return }
        isFetchingPlan = true
        fetchError = nil

        Task {
            let result = await planAPI.fetchPlan(id: targetId)
            var workoutIdToFetch: String?
            await MainActor.run {
                switch result {
                case .success(let plan):
                    clientPlan = plan
                    expandedWeeks = [:]
                    workoutIdToFetch = plan.currentWorkout?.id
                case .failure(let error):
                    fetchError = "Failed to load plan: \(error.localizedDescription)"
                }
                isFetchingPlan = false
            }

            // Fetch current workout detail via SDK
            if let wId = workoutIdToFetch {
                let wResult = await kinestex.fetchWorkout(id: wId)
                await MainActor.run {
                    switch wResult {
                    case .success(let model):
                        currentWorkoutModel = model
                        print("[PlanOnboarding] Workout loaded: \(model.title) (\(model.sequence.count) exercises)")
                    case .failure(let error):
                        print("[PlanOnboarding] Workout fetch failed: \(error.localizedDescription)")
                    }
                }
            }

            // Also fetch personal plan if type is personalized
            if planType == "personalized" {
                let personalResult = await planAPI.fetchPersonalPlan()
                await MainActor.run {
                    switch personalResult {
                    case .success(let plan):
                        personalPlan = plan
                        print("[PlanOnboarding] Personal plan loaded - week: \(plan.current_week ?? 0), day: \(plan.current_day ?? 0)")
                    case .failure(let error):
                        print("[PlanOnboarding] Personal plan fetch failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    PlanOnboardingView()
}
