### Key Features of Personalized Workout Plan

- **Personalized**: Tailored to height, weight, age, gender, activity level, and fitness assessment results.
- **Goal-Oriented**: Supports strength, flexibility, and wellness goals.
- **Seamless Experience**: From recommendations to real-time feedback.
- **Customizable**: Brand-aligned app design.
- **Quick Integration**: Easy setup for advanced fitness solutions.


# **Plan Integration Example**

```swift
kinestex.createPersonalizedPlanView(
    user: nil, // OPTIONAL: provide user details
    isLoading: $isLoading,
    customParams: ["style": "dark"], // dark or light theme (customizable in admin portal)
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(_):
             showKinesteX = false // dismiss the view
        default:
            print("Received \(message)")
            break
        }
    }
)

``` 

# Next steps:
- ### [View onMessageReceived available data points](../../data.md)
- ### [Explore more integration options](../overview.md)
