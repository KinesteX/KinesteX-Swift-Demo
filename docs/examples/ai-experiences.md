Complete code example for the `createExperienceView` function:
```swift
import SwiftUI
import KinesteXAIFramework

struct ExperienceIntegrationView: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Replace with your KinesteX credentials
    let apiKey = "YOUR API KEY"
    let company = "YOUR COMPANY NAME"
    let userId = "YOUR USER ID"

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
                Text("Start 'Box' Experience")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.cornerRadius(10))
                    .padding(.horizontal)
            }
            .padding()

            Spacer()
        }
        .fullScreenCover(isPresented: $showKinesteX) {
            // AI Experience Integration
            KinesteXAIFramework.createExperienceView(
                apiKey: apiKey,
                companyName: company,
                userId: userId,
                experience: "box", // Name of the AI experience
                user: nil,
                isLoading: $isLoading,
                customParams: ["style": "dark"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss the experience view
                    default:
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