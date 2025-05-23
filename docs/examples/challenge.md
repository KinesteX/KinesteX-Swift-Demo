Complete example for Challenge view
```swift
import SwiftUI
import KinesteXAIKit // Import the new module

struct ChallengeIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Initialize KinesteXAIKit
    // Replace with your KinesteX credentials
    let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR API KEY",
        companyName: "YOUR COMPANY NAME",
        userId: "YOUR USER ID"
    )

    // Challenge parameters
    let challengeExercise = "Squats"
    let challengeDuration = 100 // Duration in seconds
    let showLeaderboardAfterChallenge = true

    var body: some View {
        VStack {
            // Header
            Text("KinesteX Challenge Integration")
                .font(.title)
                .padding()

            Spacer()

            // Start Challenge Button
            Button(action: {
                showKinesteX.toggle()
            }) {
                Text("Start \(challengeExercise) Challenge (\(challengeDuration)s)")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.cornerRadius(10)) // Changed color
                    .padding(.horizontal)
            }
            .padding()

            Spacer()
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // Challenge Integration View using the KinesteXAIKit instance
            kinesteXKit.createChallengeView(
                exercise: challengeExercise,
                duration: challengeDuration, // Parameter name changed from countdown
                showLeaderboard: showLeaderboardAfterChallenge, // Optional, defaults to true
                user: nil, // Optional user details
                isLoading: $isLoading,
                customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss challenge view
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
    ChallengeIntegrationView()
}
```