### Immersive AI Experiences: Engage and Motivate

- **AI-Powered Fitness**: Interactive workouts driven by advanced motion analysis.  
- **"Fight with a Shadow"**: Virtual punching bag reacts to hits, enhancing technique and engagement.  
- **Real-Time Feedback**: Improve stance, punches, and form with AI guidance.  


# **EXPERIENCE Integration Example**

```swift
KinesteXAIFramework.createExperienceView(
  apiKey: apiKey, // Your unique API key
  companyName: company, // Name of your company
  userId: userId, // Unique identifier for the user
  experience: "box", // Specify the experience (e.g., "box")
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