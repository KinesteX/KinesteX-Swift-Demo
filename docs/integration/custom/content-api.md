# KinesteX Workout, Plans, and Exercises API

KinesteXAIFramework, through the `KinesteXAIKit`, enables you to fetch our diverse content data such as workouts, plans, and exercises. Whether you're building a fitness app, a training platform, or any content-driven application, `KinesteXAIKit` provides a robust and easy-to-use API to enhance your app's functionality.

## Features

- **Flexible Content Fetching:** Retrieve workouts, plans, and exercises based on various parameters and filters using `KinesteXAIKit`.
- **Robust Models:** Comprehensive data models representing different content types.
- **Asynchronous Operations:** Efficient data fetching with `async/await` support.
- **Error Handling:** Detailed error messages and validation to ensure data integrity.
- **Easy Integration:** Simple API designed for swift integration into SwiftUI or UIKit projects.

## Installation

### Swift Package Manager

KinesteXAIFramework is available through [Swift Package Manager](https://swift.org/package-manager/). To integrate it into your project:

1.  Open your project in Xcode.
2.  Navigate to **File > Add Packages**.
3.  Enter the repository URL:
    ```
    https://github.com/KinesteX/KinesteX-AI-Kit.git
    ```
4.  Choose the latest version and add the package to your project.

## Usage

### Initializing KinesteXAIKit

Before fetching content, you need to initialize an instance of `KinesteXAIKit` with your API key, company name, and a user ID.

```swift
import KinesteXAIKit
import SwiftUI // Or UIKit

// Initialize KinesteXAIKit
let kit = KinesteXAIKit(apiKey: "yourApiKey",
                        companyName: "YourCompany",
                        userId: "currentUser_123")
```

### Fetching Content Data

To fetch content data such as workouts, plans, or exercises, use the `fetchContent` method on your `KinesteXAIKit` instance. This asynchronous function allows you to specify `contentType` and various filtering options such as `id`, `title`, `category`, and `bodyParts`.

Alternatively, `KinesteXAIKit` provides convenient helper methods like `fetchWorkouts`, `fetchExercises`, `fetchPlans`, `fetchWorkout(id:)`, `fetchExercise(id:)`, and `fetchPlan(id:)` that simplify fetching specific content types and handle results using Swift's `Result` type.

#### Parameters for `fetchContent`:

- `contentType` (ContentType): The type of content to fetch (`.workout`, `.plan`, `.exercise`).
- `id` (String?, optional): Unique identifier for the content. Overrides other search parameters if provided.
- `title` (String?, optional): Title to search for the content when `id` is not provided.
- `category` (String?, optional): Category to filter workouts and plans.
- `bodyParts` ([BodyPart]?, optional): Array of `BodyPart` to filter workouts, plans, and exercises.
- `lang` (String, optional): Language for the content (default is `"en"`).
- `lastDocId` (String?, optional): Document ID for pagination; fetches content after this ID.
- `limit` (Int?, optional): Limit on the number of items to fetch.

### Models

KinesteXAIFramework includes several data models representing different content types:

- **WorkoutModel:** Details about a workout.
- **ExerciseModel:** Details about an exercise.
- **PlanModel:** Information about a workout plan.
- **Additional Models:** Supporting models like `PlanModelCategory`, `PlanLevel`, `PlanDay`, and `WorkoutSummary`.
- **Response Models:** `WorkoutsResponse`, `ExercisesResponse`, `PlansResponse` for handling paginated list results.
- **BodyPart Enum:** Represents body parts for filtering content.
- **ContentType Enum:** Represents the type of content to fetch.

### Using Filtering Options with `KinesteXAIKit`

#### Fetching Workouts by Category (using `fetchWorkouts` helper)

```swift
import KinesteXAIKit

// Assume 'kit' is an initialized KinesteXAIKit instance
// let kit = KinesteXAIKit(apiKey: "yourApiKey", companyName: "MyCompany", userId: "user123")

Task {
    let result = await kit.fetchWorkouts(category: "Fitness", // "Rehabilitation"
                                         limit: 5)
    switch result {
    case .success(let workoutsResponse):
        let workouts = workoutsResponse.workouts
        // Handle workouts data
        print("Fetched \(workouts.count) workouts.")
    case .failure(let error):
        print("Error fetching workouts: \(error.localizedDescription)")
    }
}
```

#### Fetching Exercises by Body Parts (using `fetchExercises` helper)

```swift
import KinesteXAIKit

// Assume 'kit' is an initialized KinesteXAIKit instance
// let kit = KinesteXAIKit(apiKey: "yourApiKey", companyName: "MyCompany", userId: "user123")

Task {
    let result = await kit.fetchExercises(bodyParts: [.abs, .glutes],
                                          limit: 10)
    switch result {
    case .success(let exercisesResponse):
        let exercises = exercisesResponse.exercises
        // Handle exercises data
        print("Fetched \(exercises.count) exercises.")
    case .failure(let error):
        print("Error fetching exercises: \(error.localizedDescription)")
    }
}
```

#### Fetching Plans by Category and Body Parts (using `fetchContent`)

Note: The `fetchPlans` helper method currently supports filtering by `category`, `limit`, and `lastDocId`. For `bodyParts` filtering with plans, you can use the general `fetchContent` method.

```swift
import KinesteXAIKit

// Assume 'kit' is an initialized KinesteXAIKit instance
// let kit = KinesteXAIKit(apiKey: "yourApiKey", companyName: "MyCompany", userId: "user123")

Task {
    let result = await kit.fetchContent(contentType: .plan,
                                        category: "Strength",
                                        bodyParts: [.biceps, .triceps],
                                        limit: 3)
    switch result {
    case .plans(let plansResponse):
        let plans = plansResponse.plans
        // Handle plans data
        print("Fetched \(plans.count) plans.")
    case .error(let message):
        print("Error fetching plans: \(message)")
    default:
        print("Unexpected result type for plans.")
    }
}
```

#### Fetching Plans by Category and `lastDocId` for pagination (using `fetchPlans` helper)

The `lastDocId` parameter is returned in your initial query (e.g., in `PlansResponse.lastDocId`) and can be used to fetch the next set of results.

```swift
import KinesteXAIKit

// Assume 'kit' is an initialized KinesteXAIKit instance and 'lastDocId' was obtained from a previous fetch
// let kit = KinesteXAIKit(apiKey: "yourApiKey", companyName: "MyCompany", userId: "user123")
var lastDocId: String? = nil // Initialize or get from previous response

Task {
    let initialResult = await kit.fetchPlans(category: "Strength", limit: 5)
    switch initialResult {
    case .success(let plansResponse):
        var plans = plansResponse.plans
        lastDocId = plansResponse.lastDocId // Store for next fetch
        print("Fetched initial \(plans.count) plans. Next ID: \(lastDocId ?? "None")")

        // To fetch the next page:
        if let nextId = lastDocId {
            let nextResult = await kit.fetchPlans(category: "Strength",
                                                  lastDocId: nextId,
                                                  limit: 5)
            switch nextResult {
            case .success(let nextPageResponse):
                plans.append(contentsOf: nextPageResponse.plans)
                lastDocId = nextPageResponse.lastDocId // Update for subsequent pages
                print("Fetched next \(nextPageResponse.plans.count) plans. Total: \(plans.count)")
            case .failure(let error):
                print("Error fetching next page of plans: \(error.localizedDescription)")
            }
        }
    case .failure(let error):
        print("Error fetching initial plans: \(error.localizedDescription)")
    }
}
```

## API Reference

### `KinesteXAIKit`

The main struct used to interact with the KinesteX API.

#### Initialization

```swift
public init(
    baseURL: URL? = nil, // Optional: Defaults to "https://kinestex.vercel.app"
    apiKey: String,
    companyName: String,
    userId: String
)
```

### `fetchContent`

A general method on a `KinesteXAIKit` instance to fetch content data from the API.

#### Signature

```swift
public func fetchContent(
    contentType: ContentType,
    id: String? = nil,
    title: String? = nil,
    lang: String = "en",
    category: String? = nil,
    bodyParts: [BodyPart]? = nil,
    lastDocId: String? = nil,
    limit: Int? = nil
) async -> APIContentResult
```

#### Parameters:

- **contentType**: The type of content to fetch (`.workout`, `.plan`, `.exercise`).
- **id**: Unique identifier for the content. Overrides other search parameters if provided.
- **title**: Title to search for the content when `id` is not provided.
- **lang**: Language for the content (default is `"en"`).
- **category**: Category to filter workouts and plans.
- **bodyParts**: Array of `BodyPart` to filter workouts, plans, and exercises.
- **lastDocId**: Document ID for pagination; fetches content after this ID.
- **limit**: Limit on the number of items to fetch.

#### Example Usage:

Refer to the [Using Filtering Options with KinesteXAIKit](#using-filtering-options-with-kinestexaikit) section above for examples.

### Helper Fetch Methods

`KinesteXAIKit` provides several helper methods that wrap `fetchContent` for easier use and typed results:

-   `fetchWorkout(id: String, lang: String = "en") async -> Result<WorkoutModel, Error>`
-   `fetchExercise(id: String, lang: String = "en") async -> Result<ExerciseModel, Error>`
-   `fetchPlan(id: String, lang: String = "en") async -> Result<PlanModel, Error>`
-   `fetchWorkouts(category: String? = nil, bodyParts: [BodyPart]? = nil, limit: Int? = 10, lastDocId: String? = nil, lang: String = "en") async -> Result<WorkoutsResponse, Error>`
-   `fetchExercises(bodyParts: [BodyPart]? = nil, limit: Int? = 10, lastDocId: String? = nil, lang: String = "en") async -> Result<ExercisesResponse, Error>`
-   `fetchPlans(category: String? = nil, limit: Int? = 10, lastDocId: String? = nil, lang: String = "en") async -> Result<PlansResponse, Error>`

These methods return a `Result` type, where `.success` contains the expected model or response, and `.failure` contains an `Error`.

### `APIContentResult`

An enumeration representing the result of a `fetchContent` API request. It can be one of the following:

-   `.workouts(WorkoutsResponse)`: Successfully fetched a list of workouts.
-   `.workout(WorkoutModel)`: Successfully fetched a single workout.
-   `.plans(PlansResponse)`: Successfully fetched a list of plans.
-   `.plan(PlanModel)`: Successfully fetched a single plan.
-   `.exercises(ExercisesResponse)`: Successfully fetched a list of exercises.
-   `.exercise(ExerciseModel)`: Successfully fetched a single exercise.
-   `.error(String)`: An error occurred with an associated message.
-   `.rawData([String: Any], String?)`: Raw JSON data was returned, possibly due to a parsing issue. The `String?` contains an optional error message.

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
    case externalOblique = "External Oblique" // Updated
    case forearms = "Forearms"
    case glutes = "Glutes"
    case neck = "Neck"
    case quads = "Quads"
    case shoulders = "Shoulders"
    case triceps = "Triceps"
    case hamstrings = "Hamstrings"
    case lats = "Lats"
    case lowerBack = "Lower Back" // Updated
    case traps = "Traps"
    case fullBody = "Full Body" // Updated

    public var id: String { self.rawValue }
}
```

## Error Handling

`KinesteXAIKit` provides error handling through the `APIContentResult` enum (specifically the `.error` and `.rawData` cases) when using `fetchContent`, and through the `Result` type's `.failure` case when using the helper fetch methods.

-   **Validation Errors:** The `KinesteXAIKit` methods internally validate input parameters like `apiKey`, `companyName`, `userId`, `lang`, `id`, `title`, `category`, and `bodyParts`. If validation fails (e.g., disallowed characters), operations may terminate early or return an error.
    ```
    ⚠️ KinesteX: Input validation failed.
    ```
-   **Network Errors:** Issues related to network connectivity will result in an error.
-   **Parsing Errors:** If data cannot be parsed correctly, helper methods will return an error in `Result.failure`. The `fetchContent` method might return the `.rawData(data, errorMessage)` case, allowing you to inspect the raw response.
-   **API Response Errors:** Errors returned by the API are captured and provided in the error messages.

**Example Error Handling (with helper method):**

```swift
Task {
    let result = await kit.fetchWorkout(id: "nonExistentId")
    switch result {
    case .success(let workout):
        // Process workout
        print("Fetched workout: \(workout.title)")
    case .failure(let error):
        // Handle error
        print("Error fetching workout: \(error.localizedDescription)")
        // You can inspect the error further if needed
        if let nsError = error as NSError? {
            if let rawData = nsError.userInfo["rawData"] as? Data {
                // Potentially inspect raw data if included in error
            }
        }
    }
}
```

**Validation for Parameters:**

-   Ensure that `category` and each `BodyPart.rawValue` in `bodyParts` (when used as strings in API calls) do not contain disallowed characters. The SDK handles appropriate encoding for URL parameters.
-   If validation fails internally, the request will terminate with an appropriate error message or an empty/error result.

## Support

For any questions, issues, or feature requests, please contact us at [support@kinestex.com](mailto:support@kinestex.com).

## Next Steps

### [> Example project](../../examples/fetch-api.md)