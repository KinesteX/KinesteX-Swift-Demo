```swift
import SwiftUI
import KinesteXAIFramework

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

class CameraViewModel: ObservableObject {
    @Published var modelWarmedUp = false
    @Published var modelsLoaded = false
    @Published var isReady = false
    @Published var isLoading = false
    @Published var shouldShowCamera = false
    
    private var hasProcessedReady = false
    
    func processMessage(type: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Processing message: \(type)")
            
            switch type {
            case "model_warmedup":
                self.modelWarmedUp = true
                self.checkAndSetReady()
            case "models_loaded":
                self.modelsLoaded = true
                self.checkAndSetReady()
            default:
                break
            }
        }
    }
    
    private func checkAndSetReady() {
        print("checkAndSetReady - warmedUp: \(modelWarmedUp), loaded: \(modelsLoaded), hasProcessed: \(hasProcessedReady)")
        guard !hasProcessedReady, modelWarmedUp, modelsLoaded else { return }
        
        hasProcessedReady = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.5)) {
                print("Setting isReady to true")
                self.isReady = true
            }
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            print("Resetting CameraViewModel state")
            self.modelWarmedUp = false
            self.modelsLoaded = false
            self.isReady = false
            self.isLoading = false
            self.shouldShowCamera = false
            self.hasProcessedReady = false
        }
    }
    
    func initializeCamera() {
        reset()
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Initializing camera component")
            self.shouldShowCamera = true
        }
    }
}

// Main app structure
struct ContentView: View {
    @StateObject private var exerciseData = ExerciseData()
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var currentScreen: Screen = .start
    
    enum Screen {
        case start
        case camera
        case results
    }
    
    // API credentials
    private let apiKey = "apikey"
    private let company = "company"
    private let userId = "user_id"
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .start:
                StartPage {
                    currentScreen = .camera
                    cameraViewModel.initializeCamera()
                }
            case .camera:
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            print("Finish button tapped - cleaning up")
                            cameraViewModel.reset()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                currentScreen = .results
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Finish")
                            }
                            .padding(12)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        if cameraViewModel.shouldShowCamera {
                            cameraView
                                .opacity(cameraViewModel.isReady ? 1.0 : 0.0)
                        }
                        
                        if !cameraViewModel.isReady {
                            loadingOverlay
                        }
                    }
                    
                    statsView
                    
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
        .animation(.default, value: currentScreen)
        .transition(.opacity)
    }
    
    private var cameraView: some View {
        KinesteXAIFramework.createCameraComponent(
            apiKey: apiKey,
            companyName: company,
            userId: userId,
            exercises: ["Thread the Needle Right"],
            currentExercise: "Thread the Needle Right",
            user: nil,
            isLoading: $cameraViewModel.isLoading,
            customParams: [
                "includeRealtimeAccuracy": true,
                "showDebugRecording": true,
                "restSpeeches": [
                    "for-squats-stand-with-your-feet-shoulder-eaeddb93689bd24704a8e7e4937cae684caacc4e"
                ]
            ],
            onMessageReceived: { message in
                print("Received message: \(message)")
                switch message {
                case .reps(let value):
                    DispatchQueue.main.async {
                        exerciseData.reps = value["value"] as? Int ?? 0
                        exerciseData.maxAccuracy = value["accuracy"] as? Double ?? 0
                    }
                case .mistake(let value):
                    DispatchQueue.main.async {
                        exerciseData.mistake = value["value"] as? String ?? "--"
                    }
                case .custom_type(let value):
                    guard let received_type = value["type"] as? String else { return }
                    cameraViewModel.processMessage(type: received_type)
                    
                    if received_type == "correct_position_accuracy" {
                        DispatchQueue.main.async {
                            exerciseData.currentAccuracy = value["accuracy"] as? Double ?? 0
                        }
                    }
                default:
                    break
                }
            }
        )
        .frame(
            width: UIScreen.main.bounds.width * 0.8,
            height: UIScreen.main.bounds.height * 0.6
        )
    }
    
    private var loadingOverlay: some View {
        VStack {
            ProgressView()
                .scaleEffect(2.0)
                .padding()
            
            Text("Loading exercise model...")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: cameraViewModel.modelWarmedUp ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(cameraViewModel.modelWarmedUp ? .green : .gray)
                    Text("Model warm-up")
                        .foregroundColor(cameraViewModel.modelWarmedUp ? .green : .primary)
                }
                
                HStack {
                    Image(systemName: cameraViewModel.modelsLoaded ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(cameraViewModel.modelsLoaded ? .green : .gray)
                    Text("Loading models")
                        .foregroundColor(cameraViewModel.modelsLoaded ? .green : .primary)
                }
            }
            .padding(.top, 20)
            
            if cameraViewModel.modelWarmedUp && cameraViewModel.modelsLoaded {
                Text("Initializing camera...")
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }
        }
        .frame(
            width: UIScreen.main.bounds.width * 0.8,
            height: UIScreen.main.bounds.height * 0.7
        )
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
    }
    
    private var statsView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                StatsCard(title: "REPS", value: "\(exerciseData.reps)")
                StatsCard(title: "Accuracy", value: "\(Int(exerciseData.maxAccuracy))%", color: .green)
            }
            
            HStack(spacing: 15) {
                StatsCard(title: "Current", value: "\(Int(exerciseData.currentAccuracy))%", color: .green)
                
                if exerciseData.mistake != "--" {
                    StatsCard(title: "MISTAKE", value: exerciseData.mistake, color: .red)
                } else {
                    StatsCard(title: "MISTAKE", value: "--", color: .gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

// Keep StartPage, StatsCard, ResultsPage, and ResultCard as they were
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
                .font(.caption)
                .fontWeight(.medium)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
}

struct ResultsPage: View {
    @ObservedObject var exerciseData: ExerciseData
    let onDoneTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Exercise Summary")
                .font(.system(size: 36, weight: .bold))
                .padding(.top, 40)
            
            Spacer()
            
            VStack(spacing: 25) {
                ResultCard(
                    icon: "flame.fill",
                    title: "Total Reps",
                    value: "\(exerciseData.reps)",
                    color: .orange
                )
                
                ResultCard(
                    icon: "chart.bar.fill",
                    title: "Max Accuracy",
                    value: "\(Int(exerciseData.maxAccuracy))%",
                    color: .green
                )
                
                if exerciseData.mistake != "--" {
                    ResultCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Mistake Detected",
                        value: exerciseData.mistake,
                        color: .red
                    )
                }
            }
            .padding(.horizontal)
            
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
            .padding(.bottom, 40)
        }
    }
}

struct ResultCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(color)
                .frame(width: 60)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```
