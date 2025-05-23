Complete code example for the `createExperienceView` function:
```swift
import SwiftUI
import KinesteXAIKit // Import the new module

struct ExperienceIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Initialize KinesteXAIKit
    // IMPORTANT: Replace placeholder values with your actual API Key, Company Name, and User ID.
    let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR_API_KEY",
        companyName: "YOUR_COMPANY_NAME",
        userId: "YOUR_USER_ID"
    )

    // Parameters for the experience
    let experienceName = "box" // Name of the AI experience
    let experienceExercise = "Boxing" // Exercise associated with the experience 
    let experienceDuration = 90 // Optional: duration in seconds, defaults to 60 in SDK

    var body: some View {
        VStack {
            // Header
            Text("KinesteX Experience Integration")
                .font(.title)
                .padding()

            Spacer()

            // Start AI Experience Button
            Button(action: {
                showKinesteX.toggle()
            }) {
                Text("Start '\(experienceName.capitalized)' Experience")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.teal.cornerRadius(10)) // Changed color
                    .padding(.horizontal)
            }
            .padding()

            Spacer()
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // AI Experience Integration using the KinesteXAIKit instance
            kinesteXKit.createExperienceView(
                experience: experienceName,
                exercise: experienceExercise, // Required exercise parameter
                duration: experienceDuration, // Optional duration
                user: nil, // Optional user details
                isLoading: $isLoading,
                customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss the experience view
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
    ExperienceIntegrationView()
}
```