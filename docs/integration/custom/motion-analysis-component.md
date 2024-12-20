### KinesteX Motion Recognition: Real-Time Engagement

- **Interactive Tracking**: Advanced motion recognition for immersive fitness experiences.  
- **Real-Time Feedback**: Instantly track reps, spot mistakes, and calculate calories burned.  
- **Boost Motivation**: Keep users engaged with detailed exercise feedback.  
- **Custom Integration**: Adapt camera placement to fit your app’s design.  

## **CAMERA Integration Example**

### **1. Displaying the KinesteX Camera Component**

```swift
KinesteXAIFramework.createCameraComponent(
    apiKey: apiKey,
    companyName: company,
    userId: userId,
    exercises: arrayAllExercises, // string array with all exercises, ex. ["Squats", "Lunges"...]
    currentExercise: currentExerciseString, // current exercise (starting)
    user: nil,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .reps(let value):
            reps = value["value"] as? Int ?? 0
        case .mistake(let value):
            mistake = value["value"] as? String ?? "--"
        default:
            break
        }
    }
)
```

### **2. Updating the Current Exercise**
Easily update the exercise being tracked through a function:

```swift
KinesteXAIFramework.updateCurrentExercise(currentExercise) // switch current exercise name in real-time (ex. "Lunges")
```

### **3. Handling Messages for Reps and Mistakes**
Track repetitions and identify mistakes made by users in real time:

```swift
KinesteXAIFramework.createCameraComponent(
    // ...
    onMessageReceived: { message in
        switch message {
          // provides current rep value for the exercise
        case .reps(let value):
            reps = value["value"] as? Int ?? 0
          // provides mistake value in real-time and speaks it to the person
        case .mistake(let value):
            mistake = value["value"] as? String ?? "--"
        // handing custom types
        case .custom_type(let value):
            guard let receivedType = value["type"] else {
                return
            }

            if let typeString = receivedType as? String {
                switch typeString {
                case "models_loaded":
                    print("ALL MODELS LOADED")
                case "person_in_frame":
                // person got into the silhouette frame
                    withAnimation {
                        personInFrame = true
                    }
                default:
                    break
                }
            }

        default:
            break
        }
    }
)

```
# Next steps
### [View complete code example](../../examples/motion-analysis.md)