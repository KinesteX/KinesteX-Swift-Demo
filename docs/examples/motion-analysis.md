Complete code example for the `createCameraComponent` function:
```swift
import SwiftUI
import KinesteXAIFramework

struct CameraIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false
    @State private var reps = 0
    @State private var mistake = ""
    @State private var personInFrame = false

    // Replace with your KinesteX credentials
    let apiKey = "YOUR API KEY"
    let company = "YOUR COMPANY NAME"
    let userId = "YOUR USER ID"

    var body: some View {
        VStack {
            // Header
            Text("KinesteX Camera Integration")
                .font(.title)
                .padding()

            Spacer()

            // Start Camera Component Button
            Button(action: {
                showKinesteX.toggle()
            }) {
                Text("Start Camera Component")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.cornerRadius(10))
                    .padding(.horizontal)
            }
            .padding()

            Spacer()

            // Display real-time feedback
            VStack {
                Text("Reps: \(reps)")
                Text("Mistake: \(mistake)").foregroundColor(.red)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // Camera Component Integration
            ZStack(alignment: .topTrailing) {
                KinesteXAIFramework.createCameraComponent(
                    apiKey: apiKey,
                    companyName: company,
                    userId: userId,
                    exercises: ["Squats", "Lunges"], // Example exercises
                    currentExercise: "Squats", // Start with "Squats"
                    user: nil,
                    isLoading: $isLoading,
                    onMessageReceived: { message in
                        switch message {
                        case .reps(let value):
                            reps = value["value"] as? Int ?? 0
                        case .mistake(let value):
                            mistake = value["value"] as? String ?? "--"
                        case .custom_type(let value):
                            guard let receivedType = value["type"] as? String else { return }
                            switch receivedType {
                            case "models_loaded":
                                print("ALL MODELS LOADED")
                            case "person_in_frame":
                                withAnimation {
                                    personInFrame = true
                                }
                            default:
                                break
                            }
                        default:
                            break
                        }
                    }
                )
                // resize the camera component
                .frame(
                    width: personInFrame ? 100 : UIScreen.main.bounds.width,
                    height: personInFrame ? 200 : UIScreen.main.bounds.height
                )
                .cornerRadius(personInFrame ? 10 : 0)
                .padding(personInFrame ? 8 : 0)

                if personInFrame {
                    VStack {
                        Text("REPS: \(reps)")
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        Text("MISTAKE: \(mistake)")
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.red)
                            .cornerRadius(5)
                    }
                    .padding(12)
                }
            }
        }
    }
}

#Preview {
    CameraIntegrationView()
}

```