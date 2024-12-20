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