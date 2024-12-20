# KinesteX Workout, Plans, and Exercises API

KinesteXAIFramework, apart from providing ready-made AI Motion Analysis solutions, enables you to fetch our diverse content data such as workouts, plans, and exercises. Whether you're building a fitness app, a training platform, or any content-driven application, KinesteXAIFramework provides a robust and easy-to-use API to enhance your app's functionality.

## Features

- **Flexible Content Fetching:** Retrieve workouts, plans, and exercises based on various parameters and filters.
- **Robust Models:** Comprehensive data models representing different content types.
- **Asynchronous Operations:** Efficient data fetching with async/await support.
- **Error Handling:** Detailed error messages and validation to ensure data integrity.
- **Easy Integration:** Simple API designed for swift integration into SwiftUI or UIKit projects.

## Installation

### Swift Package Manager

KinesteXAIFramework is available through [Swift Package Manager](https://swift.org/package-manager/). To integrate it into your project:

1. Open your project in Xcode.
2. Navigate to **File > Add Packages**.
3. Enter the repository URL:

   ```
   https://github.com/KinesteX/KinesteX-SDK-Swift.git
   ```

4. Choose the latest version and add the package to your project.

## Usage

### Fetching Content Data

To fetch content data such as workouts, plans, or exercises, use the `fetchAPIContentData` function. This function allows you to specify parameters like `apiKey`, `companyName`, `contentType`, and various filtering options such as `id`, `title`, `category`, and `bodyParts`.

#### Parameters:

- `apiKey` (String): Your API key for authentication.
- `companyName` (String): The name of your company.
- `contentType` (ContentType): The type of content to fetch (`.workout`, `.plan`, `.exercise`).
- `id` (String?, optional): Unique identifier for the content. Overrides other search parameters if provided.
- `title` (String?, optional): Title to search for the content when `id` is not provided.
- `category` (String?, optional): Category to filter workouts and plans.
- `bodyParts` ([BodyPart]?, optional): Array of `BodyPart` to filter workouts, plans, and exercises.
- `lang` (String, optional): Language for the content (default is `"en"`).
- `lastDocId` (String?, optional): Document ID for pagination; fetches content after this ID.
- `limit` (Int?, optional): Limit on the number of items to fetch.
- `completion` ((APIContentResult) -> Void): Completion handler returning the result.

### Models

KinesteXAIFramework includes several data models representing different content types:

- **WorkoutModel:** Details about a workout.
- **ExerciseModel:** Details about an exercise.
- **PlanModel:** Information about a workout plan.
- **Additional Models:** Supporting models like `PlanModelCategory`, `PlanLevel`, `PlanDay`, and `WorkoutSummary`.
- **BodyPart Enum:** Represents body parts for filtering content.


### Using the New Filtering Options

#### Fetching Workouts by Category

```swift
fetchAPIContentData(apiKey: "yourApiKey",
                    companyName: "MyCompany",
                    contentType: .workout,
                    category: "Fitness", // another available parameter "Rehabilitation"
                    limit: 5) { result in
    switch result {
    case .workouts(let workoutsResponse):
        let workouts = workoutsResponse.workouts
        // Handle workouts data
    case .error(let message):
        print("Error: \(message)")
    }
}
```

#### Fetching Exercises by Body Parts

```swift
fetchAPIContentData(apiKey: apiKey,
                    companyName: company,
                    contentType: .exercise,
                    bodyParts: [.abs, .glutes],
                    limit: 10) { result in
    switch result {
    case .exercises(let exercisesResponse):
        let exercises = exercisesResponse.exercises
        // Handle exercises data
    case .error(let message):
        print("Error: \(message)")
    }
}
```

#### Fetching Plans by Category and Body Parts

```swift
fetchAPIContentData(apiKey: apiKey,
                    companyName: company,
                    contentType: .plan,
                    category: "Strength",
                    bodyParts: [.biceps, .triceps],
                    limit: 3) { result in
    switch result {
    case .plans(let plansResponse):
        let plans = plansResponse.plans
        // Handle plans data
    case .error(let message):
        print("Error: \(message)")
    }
}
```

#### Fetching Plans by Category and `lastDocId` for pagination
`lastDocId` parameter is returned on your initial query and represents the current document id for the request, so you can continue the request
```swift
fetchAPIContentData(apiKey: apiKey,
                    companyName: company,
                    contentType: .plan,
                    category: "Strength",
                    lastDocId: lastDocId
                    limit: 5) { result in
    switch result {
    case .plans(let plansResponse):
        let plans = plansResponse.plans
        lastDocId = plansResponse.lastDocId // update the lastDocId
        // Handle plans data
    case .error(let message):
        print("Error: \(message)")
    }
}
```

## API Reference

### `fetchAPIContentData`

Fetches content data from the API based on provided parameters such as `apiKey`, `companyName`, `contentType`, and various filtering options like `id`, `title`, `category`, and `bodyParts`. This function retrieves data for specific content types (workouts, plans, or exercises) and returns the parsed result using a completion handler.

#### Signature

```swift
public static func fetchAPIContentData(
    apiKey: String,
    companyName: String,
    contentType: ContentType,
    id: String? = nil,
    title: String? = nil,
    lang: String = "en",
    category: String? = nil,
    lastDocId: String? = nil,
    limit: Int? = nil,
    bodyParts: [BodyPart]? = nil,
    completion: @escaping (APIContentResult) -> Void
) async

```

#### Parameters:

- **apiKey**: Your API key for authentication.
- **companyName**: The name of your company.
- **contentType**: The type of content to fetch (`.workout`, `.plan`, `.exercise`).
- **id**: Unique identifier for the content. Overrides other search parameters if provided.
- **title**: Title to search for the content when `id` is not provided.
- **lang**: Language for the content (default is `"en"`).
- **category**: Category to filter workouts and plans.
- **lastDocId**: Document ID for pagination; fetches content after this ID.
- **limit**: Limit on the number of items to fetch.
- **bodyParts**: Array of `BodyPart` to filter workouts, plans, and exercises.
- **completion**: Completion handler returning the result.

#### Example Usage

Refer to the [Using the New Filtering Options](#using-the-new-filtering-options) section above for examples.

### `APIContentResult`

An enumeration representing the result of an API request. It can be one of the following:

- `.workouts(WorkoutsResponse)`: Successfully fetched workouts.
- `.workout(WorkoutModel)`: Successfully fetched a single workout.
- `.plans(PlansResponse)`: Successfully fetched plans.
- `.plan(PlanModel)`: Successfully fetched a single plan.
- `.exercises(ExerciseResponse)`: Successfully fetched exercises.
- `.exercise(ExerciseModel)`: Successfully fetched a single exercise.
- `.error(String)`: An error occurred with an associated message.

### `ContentType` Enum

Represents the types of content that can be fetched.

```swift
public enum ContentType: String, CaseIterable, Identifiable {
    case workout = "Workout"
    case plan = "Plan"
    case exercise = "Exercise"
    
    public var id: String { self.rawValue }
}
```

### `BodyPart` Enum

An enumeration representing the body parts that can be used for filtering content.

```swift
public enum BodyPart: String, CaseIterable, Identifiable {
    case abs = "Abs"
    case biceps = "Biceps"
    case calves = "Calves"
    case chest = "Chest"
    case external_oblique = "External Oblique"
    case forearms = "Forearms"
    case glutes = "Glutes"
    case neck = "Neck"
    case quads = "Quads"
    case shoulders = "Shoulders"
    case triceps = "Triceps"
    case hamstrings = "Hamstrings"
    case lats = "Lats"
    case lower_back = "Lower Back"
    case traps = "Traps"
    case full_body = "Full Body"
    
    public var id: String { self.rawValue }
}
```

## Error Handling

KinesteXAIFramework provides comprehensive error handling to ensure smooth integration and debugging:

- **Validation Errors:** Checks for disallowed characters in `apiKey`, `companyName`, `lang`, `id`, `title`, `category`, and `bodyParts` parameters.
- **Network Errors:** Handles issues related to network connectivity.
- **Parsing Errors:** Provides detailed messages if the data cannot be parsed correctly.
- **API Response Errors:** Captures and displays error messages returned by the API.

**Example Error Handling:**

```swift
completion(.error("⚠️ Validation Error: apiKey, companyName, or lang contains disallowed characters"))
```

**Validation for New Parameters:**

- Ensures that `category` and each `BodyPart` in `bodyParts` do not contain disallowed characters.
- If validation fails, the request will terminate with an appropriate error message.

## Support

For any questions, issues, or feature requests, please contact us at [support@kinestex.com](mailto:support@kinestex.com).

# Next Steps
### [> Example project](../../examples/fetch-api.md)