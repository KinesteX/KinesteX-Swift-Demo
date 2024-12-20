Complete example for Challenge view
```swift
import SwiftUI
import KinesteXAIFramework

struct ChallengeIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Replace with your KinesteX credentials
    let apiKey = "YOUR API KEY"
    let company = "YOUR COMPANY NAME"
    let userId = "YOUR USER ID"

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
                Text("Start Squats Challenge")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.cornerRadius(10))
                    .padding(.horizontal)
            }
            .padding()

            Spacer()
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // Challenge Integration View
            KinesteXAIFramework.createChallengeView(
                apiKey: apiKey,
                companyName: company,
                userId: userId,
                exercise: "Squats", // Fixed to "Squats" challenge
                countdown: 100, // Challenge duration in seconds
                user: nil,
                isLoading: $isLoading,
                customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss challenge view
                    default:
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