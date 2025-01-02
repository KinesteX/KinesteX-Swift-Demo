### Exciting Challenges: Drive Engagement and Motivation

- **Fun and Competitive**: Quick challenges with leaderboards for friendly competition.  
- **Boost Activity**: Keep fitness exciting and rewarding for users.  
- **Easy Integration**: Add dynamic challenges effortlessly to your app.  

# **CHALLENGE Integration Example**

```swift
KinesteXAIFramework.createChallengeView(
    apiKey: apiKey,
    companyName: company,
    userId: userId,
    exercise: challengeExercise, // exercise name or ID
    countdown: 100, // duration of challenge in seconds
    user: nil, // Optionally pass user details
    showLeaderboard: true, // showLeaderboard prompts a user to enter a challenge at the end of the workout (true by default)
    isLoading: $isLoading,
    customParams: ["style": "dark"], // dark or light theme (customizable in admin portal)
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(let data):
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
- ### [Show Leaderboard Fullscreen](./leaderboard.md)
- ### [View complete code example](../../examples/challenge.md)
- ### [Explore more integration options](../overview.md)
