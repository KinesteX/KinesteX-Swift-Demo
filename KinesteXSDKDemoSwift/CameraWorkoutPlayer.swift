//
//  WorkoutPlayerView.swift
//  KinesteXSDKDemoSwift
//
//  Created by T3 Chat on 7/24/25.
//

import AVKit
import KinesteXAIKit
import SwiftUI

/// Manages the overall state of the workout player.
enum WorkoutState {
    /// The initial state, waiting for the user to be detected by the camera.
    case waitingForUser
    /// The user is in frame and the workout sequence (rest/exercise) is active.
    case inProgress
}

/// A workout player that launches the camera instantly and starts the workout
/// sequence only after the user is detected in the frame.
struct WorkoutPlayerView: View {
    // MARK: - Properties
    
    private let kinestex = KinesteXAIKit(
        apiKey: "YOUR_API_KEY",
        companyName: "YOUR_COMPANY_NAME",
        userId: "YOUR_USER_ID"
    )
    private let workout: WorkoutModel

    // MARK: - State Variables
    
    @State private var workoutState: WorkoutState = .waitingForUser
    @State private var sequenceIndex = 0
    @State private var isLoading = true
    @State private var currentExercise = "Pause Exercise"
    @State private var currentRestSpeech: String? = nil
    @State private var currentStepTitle = "Get Ready"
    @State private var videoPlayer: AVPlayer?
    
    // --- ADDED: State for rep counter ---
    @State private var repCount = 0

    // MARK: - Initializer
    
    init(workout: WorkoutModel) {
        self.workout = workout
    }

    // MARK: - Main View Body

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // The Camera view is ALWAYS present.
                kinestex.createCameraView(
                    exercises: workout.sequence.map { $0.modelId },
                    currentExercise: $currentExercise,
                    currentRestSpeech: $currentRestSpeech,
                    user: nil,
                    style: nil,
                    isLoading: $isLoading,
                    customParams: [
                        "restSpeeches": workout.sequence.map { $0.restSpeech },
                    ],
                    onMessageReceived: { message in
                        handleSDKMessage(message)
                    }
                )
                .frame(
                    width: (isRestStep() && workoutState == .inProgress)
                        ? 0 : UIScreen.main.bounds.width,
                    height: (isRestStep() && workoutState == .inProgress)
                        ? 0 : nil
                )
                .clipped()

                // The Video player is shown only during active rest steps.
                if let player = videoPlayer {
                    VideoPlayer(player: player)
                        .opacity(isRestStep() && workoutState == .inProgress ? 1 : 0)
                        .onAppear { player.play() }
                        .onDisappear { player.pause() }
                }
                
                // --- ADDED: Rep Counter Overlay ---
                repCounterOverlay
            }
            playerNavigationBar
        }
        .onAppear(perform: setupInitialState)
        .ignoresSafeArea()
        .background(Color.black)
    }

    // MARK: - UI Components
    
    /// A view that displays the current rep count.
    @ViewBuilder
    private var repCounterOverlay: some View {
        // Only show the counter during an active exercise.
        if !isRestStep() && workoutState == .inProgress {
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("REPS")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(repCount)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                }
                .padding()
                Spacer()
            }
        }
    }

    private var playerNavigationBar: some View {
        HStack {
            Button(action: { cycleStep(forward: false) }) {
                Image(systemName: "chevron.left")
            }
            .disabled(sequenceIndex == 0 || workoutState != .inProgress)
            
            Spacer()
            Text(currentStepTitle).font(.headline.bold())
            Spacer()
            
            Button(action: { cycleStep(forward: true) }) {
                Image(systemName: "chevron.right")
            }
            .disabled(
                sequenceIndex >= workout.sequence.count * 2 - 1
                    || workoutState != .inProgress
            )
        }
        .foregroundColor(.white)
        .font(.title)
        .padding(.horizontal, 30)
        .frame(height: 60)
        .background(Color.black.opacity(0.5))
    }

    // MARK: - Logic and Helper Functions

    private func setupInitialState() {
        currentStepTitle = "Get in Frame"
        currentExercise = "Pause Exercise"
        currentRestSpeech = nil
    }
    
    private func handleSDKMessage(_ message: KinestexMessage) {
        switch message {
        case .custom_type(let value):
            guard let receivedType = value["type"] as? String else { return }
            
            if receivedType == "person_in_frame"
                && workoutState == .waitingForUser
            {
                workoutState = .inProgress
                updateStateForCurrentIndex()
            }
        // --- ADDED: Handle the reps message from the SDK ---
        case .reps(let value):
            if let count = value["value"] as? Int {
                self.repCount = count
            }
        default:
            break
        }
    }

    private func isRestStep() -> Bool {
        return sequenceIndex % 2 == 0
    }

    private func updateStateForCurrentIndex() {
        // --- ADDED: Reset rep count on every step change ---
        repCount = 0
        
        guard workoutState == .inProgress else { return }
        
        if isRestStep() {
            let exerciseIndex = sequenceIndex / 2
            guard exerciseIndex < workout.sequence.count else { return }
            let exercise = workout.sequence[exerciseIndex]
            
            currentStepTitle = "Rest: \(exercise.title)"
            currentExercise = "Pause Exercise"
            currentRestSpeech = exercise.restSpeech
            if let url = URL(string: exercise.videoURL) {
                videoPlayer = AVPlayer(url: url)
            }
        } else {
            let exerciseIndex = (sequenceIndex - 1) / 2
            guard exerciseIndex < workout.sequence.count else { return }
            let exercise = workout.sequence[exerciseIndex]
            
            currentStepTitle = exercise.title
            currentExercise = exercise.modelId
            currentRestSpeech = nil
            videoPlayer?.pause()
            videoPlayer = nil
        }
    }

    private func cycleStep(forward: Bool) {
        guard workoutState == .inProgress else { return }
        
        let maxIndex = workout.sequence.count * 2 - 1
        var newIndex = sequenceIndex
        if forward { newIndex += 1 } else { newIndex -= 1 }
        
        if newIndex >= 0 && newIndex <= maxIndex {
            sequenceIndex = newIndex
            updateStateForCurrentIndex()
        }
    }
}

// MARK: - Xcode Preview

#Preview {
    WorkoutLoaderView()
}
