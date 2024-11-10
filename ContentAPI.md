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

### Example: APIDemoView with Filtering

Below is an example of how to use KinesteXAIFramework in a SwiftUI view to fetch and display content data with the new filtering options.

```swift
import SwiftUI
import KinesteXAIFramework

struct APIDemoView: View {
    enum SearchType: String, CaseIterable, Identifiable {
        case findById = "Find by ID"
        case findByTitle = "Find by Title"
        var id: String { self.rawValue }
    }
    enum FilterType: String, CaseIterable, Identifiable {
        case none = "None"
        case category = "Category"
        case bodyParts = "Body Parts"
        var id: String { self.rawValue }
    }

    // State variables
    @State private var selectedContentType: ContentType = .workout
    @State private var selectedFilterType: FilterType = .none
    @State private var selectedSearchType: SearchType = .findById
    @State private var searchText: String = ""
    @State private var selectedBodyParts: Set<BodyPart> = []
    @State private var fetchedWorkout: WorkoutModel?
    @State private var fetchedWorkouts: [WorkoutModel]?
    @State private var fetchedExercises: [ExerciseModel]?
    @State private var fetchedPlans: [PlanModel]?
    @State private var fetchedExercise: ExerciseModel?
    @State private var presentDataView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var fetchedPlan: PlanModel?
    let apiKey = "YOUR_API_KEY" // store this key securely
    let company = "YOUR_COMPANY_NAME"

    var body: some View {
        VStack(spacing: 20) {
            // Content Type Picker
            VStack(alignment: .leading) {
                Text("Select Content Type:")
                    .font(.headline)
                
                Picker("Content Type", selection: $selectedContentType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            // Filter By Type Picker
            VStack(alignment: .leading) {
                Text("Filter By:")
                    .font(.headline)
                
                Picker("Filter Type", selection: $selectedFilterType) {
                    ForEach(FilterType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if selectedFilterType == .category {
                // Category search field
                VStack(alignment: .leading) {
                    Text("Enter category")
                        .font(.headline)
                    
                    TextField(
                        "Enter category",
                        text: $searchText
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
            } else if selectedFilterType == .bodyParts {
                // Body parts selection
                VStack(alignment: .leading) {
                    Text("Select Body Parts:")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                                Button(action: {
                                    if selectedBodyParts.contains(bodyPart) {
                                        selectedBodyParts.remove(bodyPart)
                                    } else {
                                        selectedBodyParts.insert(bodyPart)
                                    }
                                }) {
                                    Text(bodyPart.rawValue)
                                        .padding(8)
                                        .background(selectedBodyParts.contains(bodyPart) ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            } else {
                // Search Type Picker
                VStack(alignment: .leading) {
                    Text("Search By:")
                        .font(.headline)
                    
                    Picker("Search Type", selection: $selectedSearchType) {
                        ForEach(SearchType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Search Field
                VStack(alignment: .leading) {
                    Text(selectedSearchType == .findById ? "Enter \(selectedContentType.rawValue) ID:" : "Enter \(selectedContentType.rawValue) Title:")
                        .font(.headline)
                    
                    TextField(
                        selectedSearchType == .findById ? "Enter ID" : "Enter Title",
                        text: $searchText
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
            }
            
            // Search Button
            Button(action: {
                // Validation and fetching data
                if selectedFilterType == .none && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    alertMessage = "\(selectedSearchType == .findById ? "ID" : "Title") cannot be empty."
                    showAlert = true
                } else if selectedFilterType == .category && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    alertMessage = "Category cannot be empty."
                    showAlert = true
                } else if selectedFilterType == .bodyParts && selectedBodyParts.isEmpty {
                    alertMessage = "Please select at least one body part."
                    showAlert = true
                } else {
                    fetchedWorkout = nil
                    fetchedExercise = nil
                    fetchedPlan = nil
                    Task {
                        isLoading = true
                        await KinesteXAIFramework.fetchAPIContentData(
                            apiKey: apiKey,
                            companyName: company,
                            contentType: selectedContentType,
                            id: (selectedFilterType == .none && selectedSearchType == .findById) ? searchText : nil,
                            title: (selectedFilterType == .none && selectedSearchType == .findByTitle) ? searchText : nil,
                            category: selectedFilterType == .category ? searchText : nil,
                            bodyParts: selectedFilterType == .bodyParts ? Array(selectedBodyParts) : nil,
                            limit: 10
                        ) { result in
                            switch result {
                            case .workout(let workout):
                                fetchedWorkout = workout
                            case .workouts(let workouts):
                                fetchedWorkouts = workouts.workouts
                            case .plans(let plans):
                                fetchedPlans = plans.plans
                            case .exercises(let exercises):
                                fetchedExercises = exercises.exercises
                            case .plan(let plan):
                                fetchedPlan = plan
                            case .exercise(let exercise):
                                fetchedExercise = exercise
                            case .error(let errorMessage):
                                alertMessage = errorMessage
                                showAlert = true
                            }
                        }
                        isLoading = false
                        if fetchedWorkout != nil || fetchedExercise != nil || fetchedPlan != nil || fetchedWorkouts != nil || fetchedPlans != nil || fetchedExercises != nil {
                            presentDataView = true
                        }
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("View \(selectedContentType.rawValue)")
                }
            }
            .disabled(isLoading || (selectedFilterType == .none && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
            .padding()
            .frame(maxWidth: .infinity)
            .background((selectedFilterType == .none && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $presentDataView) {
            NavigationView {
                VStack {
                    if let workout = fetchedWorkout {
                        // Display workout details
                    } else if let exercise = fetchedExercise {
                        // Display exercise details
                    } else if let plan = fetchedPlan {
                        // Display plan details
                    } else {
                        // Display list of fetched content
                    }
                }
                .navigationTitle("Content Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            presentDataView = false
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
```

### Using the New Filtering Options

#### Fetching Workouts by Category

```swift
fetchAPIContentData(apiKey: "yourApiKey",
                    companyName: "MyCompany",
                    contentType: .workout,
                    category: "Cardio",
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
fetchAPIContentData(apiKey: "yourApiKey",
                    companyName: "MyCompany",
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
fetchAPIContentData(apiKey: "yourApiKey",
                    companyName: "MyCompany",
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
fetchAPIContentData(apiKey: "yourApiKey",
                    companyName: "MyCompany",
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
public static func fetchAPIContentData(apiKey: String,
                                       companyName: String,
                                       contentType: ContentType,
                                       id: String? = nil,
                                       title: String? = nil,
                                       lang: String = "en",
                                       category: String? = nil,
                                       lastDocId: String? = nil,
                                       limit: Int? = nil,
                                       bodyParts: [BodyPart]? = nil,
                                       completion: @escaping (APIContentResult) -> Void) async
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
