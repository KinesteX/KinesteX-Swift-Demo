### Key Features of Our Workout Plans

- **Personalized**: Tailored to height, weight, age, and activity level.
- **Goal-Oriented**: Supports strength, flexibility, and wellness goals.
- **Seamless Experience**: From recommendations to real-time feedback.
- **Customizable**: Brand-aligned app design.
- **Quick Integration**: Easy setup for advanced fitness solutions.

You can find exercises in our library [here](https://workout-view.kinestex.com/?tab=exercises), or create your own exercises in our [admin portal](https://admin.kinestex.com).


# **PLAN Integration Example**

```swift
KinesteXAIFramework.createPlanView(
    apiKey: apiKey,
    companyName: company,
    userId: userId,
    planName: selectedPlan, // name or ID of the plan (string)
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
- ### [View complete code example](../../examples/plans.md)
- ### [Explore more integration options](../overview.md)
