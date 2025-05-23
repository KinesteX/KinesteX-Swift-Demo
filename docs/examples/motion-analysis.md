Complete code example for the `createCameraView` function:
```swift
import SwiftUI
import KinesteXAIKit // Import the new module

struct ContentView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false
    @State private var reps = 0
    @State private var mistake = ""
    @State private var personInFrame = false

    // Add a @State variable for the current exercise
    @State private var currentExerciseName: String = "Squats" // Initial exercise

    // Initialize KinesteXAIKit
    // Replace with your KinesteX credentials
    let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR API KEY",
        companyName: "YOUR COMPANY NAME",
        userId: "YOUR USER ID"
    )

    let exercisesList = ["Squats", "Lunges"] // Example exercises

    var body: some View {
        VStack {
            // Header
            Text("KinesteX Camera Integration")
                .font(.title)
                .padding()

            // Picker to change exercise (optional, for demonstration)
            Picker("Select Exercise", selection: $currentExerciseName) {
                ForEach(exercisesList, id: \.self) { exercise in
                    Text(exercise)
                }
            }
            .padding()
            .disabled(showKinesteX) // Disable picker when camera is active

            Spacer()

            // Start Camera Component Button
            Button(action: {
                showKinesteX.toggle()
            }) {
                Text("Start Camera for \(currentExerciseName)")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.cornerRadius(10)) // Changed color for distinction
                    .padding(.horizontal)
            }
            .padding()

            Spacer()

            // Display real-time feedback
            VStack {
                Text("Reps: \(reps)")
                Text("Mistake: \(mistake)").foregroundColor(.red)
                Text("Person in Frame: \(personInFrame ? "Yes" : "No")")
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // Camera Component Integration
            ZStack(alignment: .topTrailing) {
                kinesteXKit.createCameraView(
                    exercises: exercisesList,
                    currentExercise: $currentExerciseName, // Pass the binding
                    // currentRestSpeech: nil, // Optional: provide a binding if needed
                    user: nil, // Optional user details
                    isLoading: $isLoading,
                    // customParams: ["someCustomKey": "someValue"], // Optional
                    onMessageReceived: { message in
                        // Reset feedback for new exercise if needed
                        // This might depend on how your app handles exercise transitions
                        // if currentExerciseName changes while the view is active.

                        switch message {
                        case .reps(let value):
                            reps = value["value"] as? Int ?? 0
                        case .mistake(let value):
                            mistake = value["value"] as? String ?? "--"
                        case .custom_type(let value):
                            guard let receivedType = value["type"] as? String else { return }
                            switch receivedType {
                            case "models_loaded":
                                print("All models loaded for \(currentExerciseName)")
                                // Reset state for the new exercise if necessary
                                reps = 0
                                mistake = ""
                            case "person_in_frame":
                                print("Person in frame: \(value["value"] ?? "unknown")")
                                if let inFrame = value["value"] as? Bool {
                                    withAnimation {
                                        personInFrame = inFrame
                                    }
                                }
                            default:
                                print("Custom message type: \(receivedType), value: \(value)")
                                break
                            }
                        case .exit_kinestex(_):
                            showKinesteX = false // Dismiss camera view
                            // Optionally reset states when exiting
                            personInFrame = false
                            reps = 0
                            mistake = ""
                        default:
                            print("Other message received: \(message)")
                            break
                        }
                    }
                )
                // resize the camera component based on personInFrame
                .frame(
                    width: personInFrame ? 150 : UIScreen.main.bounds.width,
                    height: personInFrame ? 250 : UIScreen.main.bounds.height
                )
                .cornerRadius(personInFrame ? 15 : 0)
                .shadow(radius: personInFrame ? 10 : 0)
                .padding(personInFrame ? 10 : 0)
                .animation(.spring(), value: personInFrame) // Animate the resize

                // Overlay for feedback when personInFrame is true and view is small
                if personInFrame {
                    VStack(alignment: .leading) {
                        Text("Exercise: \(currentExerciseName)")
                            .font(.caption)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        Text("REPS: \(reps)")
                            .font(.caption)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        if !mistake.isEmpty && mistake != "--" {
                            Text("MISTAKE: \(mistake)")
                                .font(.caption)
                                .padding(4)
                                .background(Color.red.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0)) // Adjust padding
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                // Close button (optional)
                Button(action: {
                    showKinesteX = false
                    personInFrame = false
                    reps = 0
                    mistake = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.8))
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, personInFrame ? 20 : 5) // Adjust padding based on size
                .padding(.top, personInFrame ? 10: 40)
            }
            .edgesIgnoringSafeArea(.all) // Ensure it covers the whole screen
        }
    }
}


```