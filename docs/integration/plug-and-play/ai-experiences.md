### Immersive AI Experiences: Engage and Motivate


# **Experience Integration Example**

```swift
kinestex.createExperienceView(
  experience: "assessment", // Specify the experience
  exercise: "balloonpop", // Exercise name or ID to display in the experience
  user: nil,
  isLoading: $isLoading, // Loading state
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
);
```

# Next steps:
- ### [View onMessageReceived available data points](../../data.md)
- ### [View complete code example](../../examples/ai-experiences.md)
- ### [Explore more integration options](../overview.md)
