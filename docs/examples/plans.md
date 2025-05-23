Complete example for Workout view
```swift
import SwiftUI
import KinesteXAIKit 

struct PlanIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Initialize KinesteXAIKit
    // Replace with your KinesteX credentials
    let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR API KEY",
        companyName: "YOUR COMPANY NAME",
        userId: "YOUR USER ID"
    )

    // Replace with the name or ID of the plan
    let planName = "Full Cardio"

    var body: some View {
        VStack {
            // Header
            Text("KinesteX Plan Integration")
                .font(.title)
                .padding()

            Spacer()

            // Start Plan Button
            Button(action: {
                showKinesteX.toggle()
            }) {
                Text("Start \(planName) Plan")
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
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // Plan Integration View using the KinesteXAIKit instance
            kinesteXKit.createPlanView(
                plan: planName, // Parameter name changed from planName
                user: nil, // Optional user details
                isLoading: $isLoading,
                customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss plan view
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
    PlanIntegrationView()
}
```