### Personalized Workouts: Anytime, Anywhere

- **Tailored for All Levels**: Workouts for strength, flexibility, or relaxation.  
- **Time-Saving**: Quick, efficient sessions with zero hassle.  
- **Engaging**: Keep users motivated with fresh, personalized routines.  
- **Easy Integration**: Add workouts seamlessly with minimal effort.  

You can find workout in our library [here](https://workout-view.kinestex.com/?tab=workouts), or create your own workouts in our [admin portal](https://admin.kinestex.com).


# **WORKOUT Integration Example**

```swift
KinesteXAIFramework.createWorkoutView(
    apiKey: apiKey,
    companyName: company,
    userId: userId,
    workoutName: selectedWorkout, // workout name or ID
    user: nil,
    isLoading: $isLoading,
    customParams: ["style": "dark"], // dark or light theme (customizable in admin portal)
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(_):
            showKinesteX = false // dismiss the view
        // handle any other messages
        default:
            print("Received \(message)")
            break
        }
    }
)
```

# Next steps:
- ### [View onMessageReceived available data points](../../data.md)
- ### [View complete code example](../../examples/workouts.md)
- ### [Explore more integration options](../overview.md)
