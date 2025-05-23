```swift
import SwiftUI
import KinesteXAIKit

// Main app state management
class ExerciseData: ObservableObject {
    @Published var reps = 0
    @Published var mistake = "--"
    @Published var maxAccuracy = 0.0
    @Published var currentAccuracy = 0.0

    func reset() {
        reps = 0
        mistake = "--"
        maxAccuracy = 0.0
        currentAccuracy = 0.0
    }
}

// CameraViewModel manages the state related to the camera component's lifecycle
class CameraViewModel: ObservableObject {
    @Published var modelWarmedUp = false
    @Published var modelsLoaded = false
    @Published var isReady = false
    @Published var isLoading = false // Bound to KinesteXAIKit's camera view
    @Published var shouldShowCamera = false

    private var hasProcessedReady = false // Prevents multiple ready state triggers

    // Processes custom messages from the KinesteX camera view
    func processMessage(type: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch type {
            case "model_warmedup": // Custom message indicating model warm-up completion
                self.modelWarmedUp = true
                self.checkAndSetReady()
            case "models_loaded": // Custom message indicating all models are loaded
                self.modelsLoaded = true
                self.checkAndSetReady()
            default:
                // Handle other custom message types if necessary
                break
            }
        }
    }

    // Checks if all conditions are met to set the camera view as ready
    private func checkAndSetReady() {
        guard !hasProcessedReady, modelWarmedUp, modelsLoaded else { return }

        hasProcessedReady = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Short delay for UI
            withAnimation(.easeIn(duration: 0.5)) {
                self.isReady = true
            }
        }
    }

    // Resets the ViewModel's state
    func reset() {
        DispatchQueue.main.async {
            self.modelWarmedUp = false
            self.modelsLoaded = false
            self.isReady = false
            self.isLoading = false
            self.shouldShowCamera = false
            self.hasProcessedReady = false
        }
    }

    // Prepares and triggers the display of the camera component
    func initializeCamera() {
        reset()
        // isLoading state is primarily managed by the binding to KinesteXAIKit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldShowCamera = true
        }
    }
}

// Main app structure
struct ContentView: View {
    @StateObject private var exerciseData = ExerciseData()
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var currentScreen: Screen = .start

    // Required for createCameraView binding; set to the desired initial exercise ID
    @State private var currentExerciseID: String = "CnOcLpBo5RAyznE0z3jt"
    // List of exercise IDs to be available in the camera view
    private let exerciseListForCamera: [String] = ["CnOcLpBo5RAyznE0z3jt"]

    enum Screen {
        case start
        case camera
        case results
    }

    // Initialize KinesteXAIKit with your credentials
    // IMPORTANT: Replace placeholder values with your actual API Key, Company Name, and User ID.
    private let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR_API_KEY",
        companyName: "YOUR_COMPANY_NAME",
        userId: "YOUR_USER_ID"
    )

    var body: some View {
        ZStack {
            switch currentScreen {
            case .start:
                StartPage {
                    currentScreen = .camera
                    cameraViewModel.initializeCamera()
                }
            case .camera:
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        Button(action: {
                            cameraViewModel.reset()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                currentScreen = .results
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Finish")
                            }
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)

                    ZStack {
                        if cameraViewModel.shouldShowCamera {
                            cameraView
                                .opacity(cameraViewModel.isReady ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.5), value: cameraViewModel.isReady)
                        }

                        if !cameraViewModel.isReady && cameraViewModel.shouldShowCamera {
                            loadingOverlay
                        }
                    }
                    .frame(
                        width: UIScreen.main.bounds.width * 0.9,
                        height: UIScreen.main.bounds.height * 0.55
                    )
                    .cornerRadius(15)
                    .shadow(radius: 5)

                    statsView
                        .padding(.top, 5)

                    Spacer()
                }
                .padding(.top)

            case .results:
                ResultsPage(exerciseData: exerciseData) {
                    exerciseData.reset()
                    cameraViewModel.reset()
                    currentScreen = .start
                }
            }
        }
        .animation(.easeInOut, value: currentScreen)
    }

    private var cameraView: some View {
        kinesteXKit.createCameraView(
            exercises: exerciseListForCamera,
            currentExercise: $currentExerciseID,
            // currentRestSpeech: Binding<String?>?, // Optional: for dynamic speech updates
            user: nil, // Optional: Pass UserDetails if available
            isLoading: $cameraViewModel.isLoading,
            customParams: [
                "includeRealtimeAccuracy": true,
                // "showDebugRecording": true, // Enable for development diagnostics if needed
                // "restSpeeches": ["speech_key_1"] // Example for pre-defined speech content
            ],
            onMessageReceived: { message in
                switch message {
                case .reps(let value):
                    DispatchQueue.main.async {
                        exerciseData.reps = value["value"] as? Int ?? exerciseData.reps
                        exerciseData.maxAccuracy = value["accuracy"] as? Double ?? exerciseData.maxAccuracy
                    }
                case .mistake(let value):
                    DispatchQueue.main.async {
                        exerciseData.mistake = value["value"] as? String ?? "--"
                    }
                case .custom_type(let value):
                    guard let received_type = value["type"] as? String else { return }
                    cameraViewModel.processMessage(type: received_type)

                    // Example: Handling a specific custom message for accuracy
                    if received_type == "correct_position_accuracy" {
                        DispatchQueue.main.async {
                            exerciseData.currentAccuracy = value["accuracy"] as? Double ?? 0.0
                        }
                    }
                    // Handle other custom messages like "person_in_frame" as needed
                case .exit_kinestex(_):
                    cameraViewModel.reset()
                    currentScreen = .start // Or navigate to results
                default:
                    break
                }
            }
        )
    }

    private var loadingOverlay: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()

            Text("Loading Exercise...")
                .font(.headline)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: cameraViewModel.modelWarmedUp ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(cameraViewModel.modelWarmedUp ? .green : .gray)
                    Text("Model Warm-up")
                        .foregroundColor(cameraViewModel.modelWarmedUp ? .green : .primary)
                }

                HStack {
                    Image(systemName: cameraViewModel.modelsLoaded ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(cameraViewModel.modelsLoaded ? .green : .gray)
                    Text("Loading Models")
                        .foregroundColor(cameraViewModel.modelsLoaded ? .green : .primary)
                }
            }
            .padding(.top, 15)

            if cameraViewModel.modelWarmedUp && cameraViewModel.modelsLoaded {
                Text("Initializing Camera...")
                    .foregroundColor(.green)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }

    private var statsView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                StatsCard(title: "REPS", value: "\(exerciseData.reps)")
                StatsCard(title: "MAX ACCURACY", value: "\(Int(exerciseData.maxAccuracy))%", color: .green)
            }

            HStack(spacing: 10) {
                StatsCard(title: "CURRENT ACCURACY", value: "\(Int(exerciseData.currentAccuracy))%", color: .cyan)

                if exerciseData.mistake != "--" && !exerciseData.mistake.isEmpty {
                    StatsCard(title: "MISTAKE", value: exerciseData.mistake, color: .red)
                } else {
                    StatsCard(title: "MISTAKE", value: "--", color: .gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

// --- Helper Views (StartPage, StatsCard, ResultsPage, ResultCard) ---
// These views are included for completeness of the example.
// No changes were made to these based on the KinesteXAIKit update itself.

struct StartPage: View {
    let onStartTapped: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Text("Exercise Tracker")
                .font(.system(size: 36, weight: .bold))
            Image(systemName: "figure.run")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            Spacer()
            Button(action: onStartTapped) {
                Text("Start Exercise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 250, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            Spacer()
        }
        .padding()
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    var color: Color = .white

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .textCase(.uppercase)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(Material.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct ResultsPage: View {
    @ObservedObject var exerciseData: ExerciseData
    let onDoneTapped: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("Exercise Summary")
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 50)
            Spacer()
            VStack(spacing: 20) {
                ResultCard(
                    icon: "flame.fill",
                    title: "Total Reps",
                    value: "\(exerciseData.reps)",
                    color: .orange
                )
                ResultCard(
                    icon: "target",
                    title: "Max Accuracy",
                    value: "\(Int(exerciseData.maxAccuracy))%",
                    color: .green
                )
                if exerciseData.mistake != "--" && !exerciseData.mistake.isEmpty {
                    ResultCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Last Mistake",
                        value: exerciseData.mistake,
                        color: .red
                    )
                }
            }
            .padding(.horizontal, 20)
            Spacer()
            Button(action: onDoneTapped) {
                Text("Back to Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 250, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct ResultCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
        }
        .padding()
        .background(Material.regularMaterial)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```
