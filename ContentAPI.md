# KinesteX Workout, Plans, and Exercises API

KinesteXAIFramework apart from ready-made AI Motion Analysis solutions enables you to fetch our diverse content data such as workouts, plans, and exercises. Whether you're building a fitness app, a training platform, or any content-driven application, KinesteXAIFramework provides a robust and easy-to-use API to enhance your app's functionality.

## Features

- **Flexible Content Fetching:** Retrieve workouts, plans, and exercises based on various parameters.
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
   `
   https://github.com/KinesteX/KinesteX-SDK-Swift.git
   `
4. Choose the latest version and add the package to your project.

## Usage

### Fetching Content Data

To fetch content data such as workouts, plans, or exercises, use the `fetchAPIContentData` function. This function allows you to specify parameters like `apiKey`, `companyName`, `contentType`, and search criteria (`id` or `title`).

#### Parameters:

- `apiKey` (String): Your API key for authentication.
- `companyName` (String): The name of your company.
- `contentType` (ContentType): The type of content to fetch (`.workout`, `.plan`, `.exercise`).
- `id` (String?, optional): Unique identifier for the content. Overrides `title` if provided.
- `title` (String?, optional): Title to search for the content when `id` is not provided.
- `lang` (String, optional): Language for the content (default is `"en"`).
- `completion` ((APIContentResult) -> Void): Completion handler returning the result.

### Models

KinesteXAIFramework includes several data models representing different content types:

- **WorkoutModel:** Details about a workout.
- **ExerciseModel:** Details about an exercise.
- **PlanModel:** Information about a workout plan.
- **Additional Models:** Supporting models like `PlanModelCategory`, `PlanLevel`, `PlanDay`, and `WorkoutSummary`.

### Example: APIDemoView

Below is an example of how to use KinesteXAIFramework in a SwiftUI view to fetch and display content data.

```swift
import SwiftUI
import KinesteXAIFramework

struct APIDemoView: View {
    
    enum SearchType: String, CaseIterable, Identifiable {
        case findById = "Find by ID"
        case findByTitle = "Find by Title"
        
        var id: String { self.rawValue }
    }
    
    // State variables
    @State private var selectedContentType: ContentType = .workout
    @State private var selectedSearchType: SearchType = .findById
    @State private var searchText: String = ""
    @State private var fetchedWorkout: WorkoutModel?
    @State private var fetchedExercise: ExerciseModel?
    @State private var presentDataView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var fetchedPlan: PlanModel?
    let apiKey = "YOUR API KEY" // store this key securely
    let company = "YOUR COMPANY NAME"
    
    var body: some View {
        VStack(spacing: 20) {
            // Content Type Picker
            VStack(alignment: .leading) {
                Text("Select Content Type:")
                    .font(.headline
                
                Picker("Content Type", selection: $selectedContentType) {
                    ForEach(ContentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
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
            
            // Search Button
            Button(action: {
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    alertMessage = "\(selectedSearchType == .findById ? "ID" : "Title") cannot be empty."
                    showAlert = true
                } else {
                    fetchedWorkout = nil
                    fetchedExercise = nil
                    fetchedPlan = nil
                    Task {
                        isLoading = true
                        await KinesteXAIFramework.fetchAPIContentData(apiKey: apiKey, companyName: company, contentType: selectedContentType, id: selectedSearchType == .findById ? searchText : nil, title: selectedSearchType == .findByTitle ? searchText : nil) { result in
                            switch result {
                            case .workout(let workout):
                                fetchedWorkout = workout
                            case .plan(let plan):
                                fetchedPlan = plan
                            case .exercise(let exercise):
                                fetchedExercise = exercise
                            case .error(let errorMessage):
                                alertMessage = errorMessage
                                showAlert = true
                                print("Error:", errorMessage)
                            }
                        }
                        isLoading = false
                        if fetchedWorkout != nil || fetchedExercise != nil || fetchedPlan != nil {
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
            .disabled(isLoading || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding()
            .frame(maxWidth: .infinity)
            .background(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $presentDataView) {
                NavigationView {
                    VStack{
                        if let workout = fetchedWorkout {
                            WorkoutDetailView(workout: workout)
                        } else if let fetchedExercise {
                            ExerciseCardView(exercise: fetchedExercise, index: 0)
                        } else if let plan = fetchedPlan {
                            PlanDetailView(plan: plan)
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

struct APIDemoView_Previews: PreviewProvider {
    static var previews: some View {
        APIDemoView()
    }
}
```

## API Reference

### `fetchAPIContentData`

Fetches content data from the API based on provided parameters such as `apiKey`, `companyName`, `contentType`, `id`, `title`, and `lang`. This function retrieves data for specific content types (workouts, plans, or exercises) and returns the parsed result using a completion handler.

#### Signature

```swift
public static func fetchAPIContentData(apiKey: String, 
                                       companyName: String, 
                                       contentType: ContentType,
                                       id: String? = nil, 
                                       title: String? = nil, 
                                       lang: String = "en",
                                       completion: @escaping (APIContentResult) -> Void) async
```

#### Example Usage

```swift
fetchAPIContentData(apiKey: "yourApiKey", 
                   companyName: "MyCompany", 
                   contentType: .workout, 
                   title: "Fitness Lite") { result in
    switch result {
    case .workout(let workout):
        // Handle workout data
    case .error(let message):
        print("Error: \(message)")
    }
}
```

### `APIContentResult`

An enumeration representing the result of an API request. It can be one of the following:

- `.workout(WorkoutModel)`: Successfully fetched a workout.
- `.plan(PlanModel)`: Successfully fetched a plan.
- `.exercise(ExerciseModel)`: Successfully fetched an exercise.
- `.error(String)`: An error occurred with an associated message.

### `ContentType`

An enumeration for the types of content that can be fetched. Each case represents a different content type:

- `.workout`: Represents workout content.
- `.plan`: Represents plan content.
- `.exercise`: Represents exercise content.

```swift
public enum ContentType: String, CaseIterable, Identifiable {
    case workout = "Workout"
    case plan = "Plan"
    case exercise = "Exercise"
    
    public var id: String { self.rawValue }
}
```

## Error Handling

KinesteXAIFramework provides comprehensive error handling to ensure smooth integration and debugging:

- **Validation Errors:** Checks for disallowed characters in `apiKey`, `companyName`, `lang`, `id`, and `title` parameters.
- **Network Errors:** Handles issues related to network connectivity.
- **Parsing Errors:** Provides detailed messages if the data cannot be parsed correctly.
- **API Response Errors:** Captures and displays error messages returned by the API.

**Example Error Handling:**

```swift
completion(.error("⚠️ Validation Error: apiKey, companyName, or lang contains disallowed characters"))
```

## Support

For any questions, issues, or feature requests, please contact us at [support@kinestex.com](mailto:support@kinestex.com).
