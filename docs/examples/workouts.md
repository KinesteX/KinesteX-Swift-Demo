Complete example for Workout view
```swift
import SwiftUI
import KinesteXAIKit // Import the new module

struct WorkoutIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Initialize KinesteXAIKit
    // Replace with your KinesteX credentials
    let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR API KEY",
        companyName: "YOUR COMPANY NAME",
        userId: "YOUR USER ID"
    )

    // Replace with the name or ID of the workout
    let workoutName = "Fitness Lite"

    var body: some View {
        VStack {
            // Header
            Text("KinesteX Workout Integration")
                .font(.title)
                .padding()

            Spacer()

            // Start Workout Button
            Button(action: {
                showKinesteX.toggle()
            }) {
                Text("Start \(workoutName) Workout")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.cornerRadius(10))
                    .padding(.horizontal)
            }
            .padding()

            Spacer()
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // Workout Integration View using the KinesteXAIKit instance
            kinesteXKit.createWorkoutView(
                workout: workoutName, // Parameter name changed from workoutName
                user: nil, // Optional user details
                isLoading: $isLoading,
                customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss workout view
                    default:
                        // Handle other messages from the KinesteX view
                        print("Message received: \(message)")
                    }
                }
            )
        }
    }
}

#Preview {
    WorkoutIntegrationView()
}

```