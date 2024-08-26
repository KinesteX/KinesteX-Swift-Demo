# [KinesteX AI Fitness SDK](https://kinestex.com)

## INTEGRATE AN AI TRAINER INTO YOUR APP IN MINUTES
### Effortlessly enhance your platform with our SDK, providing white-labeled workouts with precise motion tracking and real-time feedback designed for maximum accuracy and engagement.

[Demo Video](https://github.com/V-m1r/KinesteX-B2B-AI-Fitness-and-Physio/assets/62508191/ac4817ca-9257-402d-81db-74e95060b153)

## Integration Options
---

### Integration Overview

| **Option**                   | **Description**                                                                                      | **Features**                                                                                                                                                  | **Details**                                                                                                                |
|------------------------------|------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| **Complete User Experience** | Let us handle the workout recommendations, motion tracking, and overall user interface. Customizable to fit your brand for a seamless experience. | - Long-term lifestyle workout plans<br> - Specific body parts and full-body workouts<br> - Individual exercise challenges (e.g., 20 squat challenge)         | [Explore Complete Experience](https://www.figma.com/proto/XYEoV023iSFdhpw3w65zR1/Complete?page-id=0%3A1&node-id=0-1&viewport=793%2C330%2C0.1&t=d7VfZzKpLBsJAcP9-1&scaling=contain) |
| **Custom User Experience**   | Integrate motion tracking with customizable camera settings. Real-time feedback for all user movements. | - Real-time movement feedback<br> - Instant communication of repetitions and mistakes<br> - Customizable camera position, size, and placement               | [Explore Custom Experience](https://www.figma.com/proto/JyPHuRKKbiQkwgiDTkGJgT/Camera-Component?page-id=0%3A1&node-id=1-4&viewport=925%2C409%2C0.22&t=3UccMcp1o3lKc0cP-1&scaling=contain) |

---

## Configuration

### Info.plist Setup

Add the following keys to enable camera and microphone usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video streaming.</string>
```

### Adding the SDK as a Package Dependency

Add the framework as a package dependency with the following URL:

```xml
https://github.com/KinesteX/KinesteX-SDK-Swift.git
```

## Integration - Main View

Create the main view with personalized AI workout plans, tracking the user's progress and guiding them through their workout schedule.

### Available Workout Plan Categories

| **enum PlanCategory** | 
| --- | 
| **Strength** | 
| **Cardio** |
| **Rehabilitation** | 
| **Weight Management** | 
| **Custom(String)** - For newly released custom plans |

### Initial Setup

1. **Prerequisites**:
    - Ensure the necessary permissions are added in `Info.plist`.
    - Minimum OS version: 13.0

2. **Launching the Main View**:
   - To display the KinesteX Complete User Experience, call `createMainView` from the `KinesteXAIFramework`:

   ```swift
    KinesteXAIFramework.createMainView(
        apiKey: apiKey,
        companyName: company,
        userId: "YOUR USER ID",
        planCategory: planCategory,
        user: nil,
        isLoading: $isLoading,
        onMessageReceived: { message in
            // Handle real-time updates and user activity
            switch message {
            case .kinestex_launched(let data):
                print("KinesteX Launched: \(data)")
            case .finished_workout(let data):
                print("Workout Finished: \(data)")
                // Additional cases as needed
            case .exit_kinestex(let data):
                dismiss() // Dismiss the view
            default:
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

## Integration - Challenge View

### Launching the Challenge View

Recommended exercises for challenges include:

```swift
"Squats", "Jumping Jack", "Burpee", "Push Ups", "Lunges", 
"Reverse Lunges", "Knee Push Ups", "Hip Thrust", "Squat Thrusts",
"Basic Crunch", "Sprinters Sit Ups", "Low Jacks", "Twisted Mountain Climber"
```

To display the KinesteX Challenge View, use `createChallengeView`:

```swift
KinesteXAIFramework.createChallengeView(
    apiKey: "your key",
    companyName: "your company",
    userId: "your userId",
    exercise: challengeExercise,
    countdown: Int,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(let data):
            dismiss()
        default:
            break
        }
    }
)
```

## Integration - Workout View

### Launching the Workout View

To display the KinesteX Workout View, use `createWorkoutView`:

```swift
KinesteXAIFramework.createWorkoutView(
    apiKey: apiKey,
    companyName: company,
    userId: "YOUR USER ID",
    workoutName: selectedWorkout,
    user: nil,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(_):
            showKinesteX = false
        default:
            break
        }
    }
)
```

## Integration - Plan View

### Launching the Plan View

To display the KinesteX Plan View, use `createPlanView`:

```swift
KinesteXAIFramework.createPlanView(
    apiKey: apiKey,
    companyName: company,
    userId: "YOUR USER ID",
    planName: selectedPlan,
    user: nil,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(_):
            showKinesteX = false
        default:
            break
        }
    }
)
```

## Integration - Camera Component

### Launching the Camera Component

To display the pose analysis view with an embedded camera component, use `createCameraComponent`:

```swift
KinesteXAIFramework.createCameraComponent(
    apiKey: apiKey,
    companyName: company,
    userId: "YOUR USER ID",
    exercises: arrayAllExercises,
    currentExercise: currentExerciseString,
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

## API Reference

### Public Functions

```swift
public struct KinesteXAIFramework {
    /**
     Creates the main view with personalized AI workout plans, tracking user progress.
     */
    public static func createMainView(apiKey: String, companyName: String, userId: String, planCategory: PlanCategory = .Cardio, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Implementation
    }

    /**
     Creates a view for a specific workout plan, tracking progress and recommending workouts.
     */
    public static func createPlanView(apiKey: String, companyName: String, userId: String, planName: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Implementation
    }

    /**
     Creates a view for a specific workout.
     */
    public static func createWorkoutView(apiKey: String, companyName: String, userId: String, workoutName: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Implementation
    }

    /**
     Creates a view for a specific exercise challenge.
     */
    public static func createChallengeView(apiKey: String, companyName: String, userId: String, exercise: String = "Squats", countdown: Int, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Implementation
    }

    /**
     Creates a camera component for real-time movement feedback.
     */
    public static func

 createCameraComponent(apiKey: String, companyName: String, userId: String, exercises: [String], currentExercise: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Implementation
    }

    /**
     Updates the current exercise in the camera component.
     */
    public static func updateCurrentExercise(_ exercise: String) {
        // Implementation
    }
}
```

## **Handling Data**:

`onMessageReceived` is a callback function that passes `enum WebViewMessage`. Available message types include:

```swift
    kinestex_launched([String: Any]) - Logs when KinesteX View is launched.
    finished_workout([String: Any]) - Logs when a workout is completed.
    error_occurred([String: Any]) - Logs errors, such as missing camera permissions.
    exercise_completed([String: Any]) - Logs when an exercise is finished.
    exit_kinestex([String: Any]) - Logs when the user exits the KinesteX view.
    workout_opened([String: Any]) - Logs when a workout description is viewed.
    workout_started([String: Any]) - Logs when a workout begins.
    plan_unlocked([String: Any]) - Logs when a workout plan is unlocked.
    custom_type([String: Any]) - Handles unrecognized messages.
    reps([String: Any]) - Logs successful repetitions.
    mistake([String: Any]) - Logs detected mistakes.
    left_camera_frame([String: Any]) - Logs when the user leaves the camera frame.
    returned_camera_frame([String: Any]) - Logs when the user returns to the camera frame.
    workout_overview([String: Any]) - Logs a workout summary upon completion.
    exercise_overview([String: Any]) - Logs a summary of completed exercises.
    workout_completed([String: Any]) - Logs when a workout is completed and the overview is exited.
```

## Available Data Types

| Type                    | Data Format                                                                                                 | Description                                                                                      |
|-------------------------|-------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `kinestex_launched`      | `dd mm yyyy hours:minutes:seconds`                                                                          | Logs when the KinesteX view is launched.                                                         |
| `exit_kinestex`          | `date: dd mm yyyy hours:minutes:seconds`, `time_spent: number`                                              | Logs when the user exits the KinesteX view, including total time spent since launch in seconds.  |
| `plan_unlocked`          | `title: String, date: date and time`                                                                        | Logs when a workout plan is unlocked.                                                            |
| `workout_opened`         | `title: String, date: date and time`                                                                        | Logs when a workout is opened.                                                                   |
| `workout_started`        | `title: String, date: date and time`                                                                        | Logs when a workout begins.                                                                      |
| `error_occurred`         | `data: string`                                                                                              | Logs significant errors, such as missing camera permissions.                                     |
| `exercise_completed`     | `time_spent: number`, `repeats: number`, `calories: number`, `exercise: string`, `mistakes: [string: number]`| Logs each completed exercise.                                                                    |
| `left_camera_frame`      | `number`                                                                                                    | Indicates when the user leaves the camera frame, with current `total_active_seconds`.           |
| `returned_camera_frame`  | `number`                                                                                                    | Indicates when the user returns to the camera frame, with current `total_active_seconds`.       |
| `workout_overview`       | `workout: string`, `total_time_spent: number`, `total_repeats: number`, `total_calories: number`, `percentage_completed: number`, `total_mistakes: number` | Logs a workout summary upon completion.                              |
| `exercise_overview`      | `[exercise_completed]`                                                                                      | Returns a log of all exercises and their data.                                                   |
| `workout_completed`      | `workout: string`, `date: dd mm yyyy hours:minutes:seconds`                                                 | Logs when a workout is completed and the user exits the overview.                               |
| `active_days` (Coming Soon) | `number`                                                                                                | Tracks the number of days the user has accessed KinesteX.                                         |
| `total_workouts` (Coming Soon) | `number`                                                                                            | Tracks the total number of workouts completed by the user.                                       |
| `workout_efficiency` (Coming Soon) | `number`                                                                                         | Measures workout intensity, with average efficiency set at 0.5, indicating 80% completion within the average timeframe. |
---

For further assistance, contact us at [support@kinestex.com](mailto:support@kinestex.com).

---
