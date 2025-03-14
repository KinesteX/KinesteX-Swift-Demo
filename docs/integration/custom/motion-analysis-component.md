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

## Additional customization options you can pass in customParams: 
| Field | Description |
|-------|-------------|
| `restSpeeches` | [String] with rest_speech values inside ExerciseModel you get from our API. When passed we will fetch the audios for use throughout the session. To use the audio you can use updateCurrentRestSpeech function (see below). |
| `videoURL` | If videoURL is specified, we will use it instead of camera |
| `landmarkColor` | Color of the pose connections and landmarks. Has to be in hex format with #. Example: "#14FF00" |
| `showSilhouette` | Whether or not to show the silhouette component prompting a user to get into the frame |
| (Beta) `includeRealtimeAccuracy` | Applies only if exercises are specified. If true will create a stream returning accuracy prediction for the correct rep value |
| `includePoseData` | string[]. Can contain either or all: ["angles", "poseLandmarks", "worldLandmarks"]. If "angles" is included, will return both 2D and 3D angles for specified poseLandmarks or/and worldLandmarks. **THIS WILL IMPACT PERFORMANCE**, so only include if you are planning to make custom calculations instead of relying on our existing exercises |

## Available message types that will be returned: 
| Event | Description |
|-------|-------------|
| `error_occurred` | includes `data` field with the error message |
| `warning` | Warning if exercise IDs models are not provided |
| `successful_repeat` | to indicate success rep, includes: `exercise` representative of currentExercise value, `value` with an integer value of the total number of reps for the current exercise, and `accuracy` value indicative of the confidence of correct rep |
| `person_in_frame` | To indicate that person is in the frame |
| `speech_fetch_complete` | Includes `successCount` and `failureCount` to indicate all `restSpeeches` phrases that have been loaded. Also each failed phrase will have `error_occurred` post message sent with the reason of the failure |
| (Beta) `correct_position_accuracy` | Includes `accuracy` field that represents how confident the system is that the person is correctly performing the current position of the exercise being tracked. For example, if currentExercise is Squats, this value will return model's confidence in correct Squat position|
| `pose_landmarks` | *If specified in includePoseData.* Includes `poseLandmarks` Object. Inside it has `coordinates`, `angles2D`, and `angles3D`. See below for all coordinate values |
| `world_landmarks` | *If specified in includePoseData.* Includes `worldLandmarks` Object. Inside it has `coordinates`, `angles2D`, and `angles3D`. See below for all coordinate values |

## Available control options:
### Pause motion tracking
To pause motion tracking specify `currentExercise` as `"Pause Exercise"` and to resume the tracking specify the exercise you want to track. Reminder: to resume the currentExercise has to be from the exercises array
```swift
KinesteXAIFramework.updateCurrentExercise("Pause Exercise") // Pause
...
KinesteXAIFramework.updateCurrentExercise("Squats") // Resume with the Model ID or Exercise name
```
### Updating current rest speech
To update the current rest speech audio and play it immediately call `updateCurrentRestSpeech` and pass any value from the restSpeeches array. Please note that the audio you pass and want to play has to be from the restSpeeches array you pass at the initialization of the component. 
```swift
KinesteXAIFramework.updateCurrentRestSpeech(restSpeeches[0]) // play the first element from the restSpeeches array
```
If audio is not being played please check logs for `error_occurred` with message: Phrase ... failed to fetch. Or alternatively listen for message `speech_fetch_complete` which will return the total successCount and failureCount for all the phrases you pass. 

## Available coordinates and angles if includePoseData is used. 
Both poseLandmarks and worldLandmarks contain same naming conventions for coordinates and angles, but have different values depending because the point of reference is different. worldLandmarks are useful if you need to perform calculations regardless of the person's position in the camera frame since the main point of reference would be hips and person will be treated as always in the center of the frame. worldLandmarks have the most accurate z measurements. poseLandmarks are useful if you need to know person's position relative to the camera frame. 

- Available coordinates:
  ```js
  nose: Landmark;
  leftEyeInner: Landmark;
  leftEye: Landmark;
  leftEyeOuter: Landmark;
  rightEyeInner: Landmark;
  rightEye: Landmark;
  rightEyeOuter: Landmark;
  leftEar: Landmark;
  rightEar: Landmark;
  mouthLeft: Landmark;
  mouthRight: Landmark;
  leftShoulder: Landmark;
  rightShoulder: Landmark;
  leftElbow: Landmark;
  rightElbow: Landmark;
  leftWrist: Landmark;
  rightWrist: Landmark;
  leftPinky: Landmark;
  rightPinky: Landmark;
  leftIndex: Landmark;
  rightIndex: Landmark;
  leftThumb: Landmark;
  rightThumb: Landmark;
  leftHip: Landmark;
  rightHip: Landmark;
  leftKnee: Landmark;
  rightKnee: Landmark;
  leftAnkle: Landmark;
  rightAnkle: Landmark;
  leftHeel: Landmark;
  rightHeel: Landmark;
  leftFootIndex: Landmark;
  rightFootIndex: Landmark;

  ```
  Each Landmark has `x`, `y`, `z`, and `visibility` fields with values from 0 to 1 indicative of person's position or visibility of the given landmark
  - Available angles both in 2D using x and y coordinates and 3D using x, y, z. 
```js
    leftKneeAngle: number;
    rightKneeAngle: number;
    leftHipAngle: number;
    rightHipAngle: number;
    leftShoulderAngle: number;
    rightShoulderAngle: number;
    leftElbowAngle: number;
    rightElbowAngle: number;
    leftWristAngle: number;
    rightWristAngle: number;
    leftAnkleAngle: number;
    rightAnkleAngle: number;
```

# Next steps
### [View complete code example](../../examples/motion-analysis.md)
