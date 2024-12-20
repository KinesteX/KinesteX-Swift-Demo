Complete example for Workout view
```swift
import SwiftUI
import KinesteXAIFramework

struct WorkoutIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Replace with your KinesteX credentials
    let apiKey = "YOUR API KEY"
    let company = "YOUR COMPANY NAME"
    let userId = "YOUR USER ID"

    // Replace with the name of the workout
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
            // Workout Integration View
            KinesteXAIFramework.createWorkoutView(
                apiKey: apiKey,
                companyName: company,
                userId: userId,
                workoutName: workoutName, // Fixed workout name
                user: nil, // Optional user details
                isLoading: $isLoading,
                 customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss workout view
                    default:
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