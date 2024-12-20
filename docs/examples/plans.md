Complete example for Workout view
```swift
import SwiftUI
import KinesteXAIFramework

struct PlanIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Replace with your KinesteX credentials
    let apiKey = "YOUR API KEY"
    let company = "YOUR COMPANY NAME"
    let userId = "YOUR USER ID"

    // Replace with the name of the plan
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
            // Plan Integration View
            KinesteXAIFramework.createPlanView(
                apiKey: apiKey,
                companyName: company,
                userId: userId,
                planName: planName, // Fixed plan name
                user: nil, // Optional user details
                isLoading: $isLoading,
                 customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss plan view
                    default:
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