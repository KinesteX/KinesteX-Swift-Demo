Complete code example for the `createCategoryView` function:
```swift
import SwiftUI
import KinesteXAIKit

struct MainViewIntegration: View {
    @State private var showKinesteX = false
    @State private var isLoading = false

    // Replace with your KinesteX credentials
    let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR API KEY",
        companyName: "YOUR COMPANY NAME",
        userId: "YOUR USER ID"
    )

    // Plan category for personalized fitness goals
    @State private var planCategory: PlanCategory = .Cardio

    var body: some View {
        VStack {
            // Header
            Text("KinesteX Main View")
                .font(.title)
                .padding()

            Spacer()

            // Start Main View Button
            Button(action: {
                showKinesteX.toggle()
            }) {
                Text("Open Main View")
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
            // Main View Integration
            kinestex.createCategoryView(
                planCategory: planCategory, // Customizable plan category
                user: nil, // Optional user details
                isLoading: $isLoading,
                customParams: ["style": "light"], // Optional styling
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false // Dismiss main view
                    default:
                        print("Message received: \(message)")
                    }
                }
            )
        }
    }
}

#Preview {
    MainViewIntegration()
}

```