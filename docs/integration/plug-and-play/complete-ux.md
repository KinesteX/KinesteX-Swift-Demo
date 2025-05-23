# Compelete User Experience (createCategoryView): 
With this integration option we displays 3 best workout plans based on the provided category. The user can select one of the plans and start a long-term routine.

Available Categories to Sort Plans

| **Plan Category (key: planCategory)** |
|---------------------------------------|
| **Strength**                          |
| **Cardio**                            |
| **Weight Management**                 |
| **Rehabilitation**                    |
| **Custom**                            |

## 1. Define the planCategory: 
```swift
       // Plan category for personalized fitness goals
    @State private var planCategory: PlanCategory = .Cardio
```
## 2. Displaying the category-based view:
  ```swift
    kinestex.createCategoryView(
        planCategory: planCategory, 
        user: user, // optional: can be nil
        isLoading: $isLoading,
        customParams: ["style": "dark"], // dark or light theme (customizable in admin portal)
        onMessageReceived: { message in
            // Handle real-time updates and user activity
            switch message {
            case .kinestex_launched(let data):
                print("KinesteX Launched: \(data)")
            case .finished_workout(let data):
                print("Workout Finished: \(data)")
                // Additional cases as needed
            case .exit_kinestex(let data):
                showKinesteX = false // Dismiss the view
            default:
                print("Received \(message)")
                break
            }
        }
    )
    // OPTIONAL: Display loading screen during view initialization
    .overlay(
        Group {
            if showAnimation {
                Text("Aifying workouts...")
                    .foregroundColor(.black)
                    .font(.caption)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .scaleEffect(showAnimation ? 1 : 3)
                    .opacity(showAnimation ? 1 : 0)
                    .animation(.easeInOut(duration: 1.5), value: showAnimation)
            }
        }
    )
    .onChange(of: isLoading) { newValue in
        withAnimation(.easeInOut(duration: 2.5)) {
            showAnimation = !newValue
        }
    }
   ```

# Next steps:
- ### [View onMessageReceived available data points](../../data.md)
- ### [View complete code example](../../examples/complete-ux.md)
- ### [Explore more integration options](../overview.md)
