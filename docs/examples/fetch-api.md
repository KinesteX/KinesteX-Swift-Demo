### Example: APIDemoView with Filtering

Below is an example of how to use KinesteX in a SwiftUI view to fetch and display content data with the new filtering options.

```swift
import SwiftUI
import KinesteXAIKit // Import the new module

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

    // Fetched data states
    @State private var fetchedWorkout: WorkoutModel?
    @State private var fetchedWorkouts: [WorkoutModel]?
    @State private var fetchedExercise: ExerciseModel?
    @State private var fetchedExercises: [ExerciseModel]?
    @State private var fetchedPlan: PlanModel?
    @State private var fetchedPlans: [PlanModel]?

    @State private var presentDataView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    // Initialize KinesteXAIKit
    // Replace with your actual credentials
    let kinesteXKit = KinesteXAIKit(
        apiKey: "YOUR_API_KEY", // store this key securely
        companyName: "YOUR_COMPANY_NAME",
        userId: "YOUR_USER_ID" // Add a user ID
    )

    var body: some View {
        NavigationView { // Added NavigationView for better title display
            VStack(spacing: 15) { // Adjusted spacing
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
                    .onChange(of: selectedFilterType) { _ in // Reset search text when filter type changes
                        searchText = ""
                        selectedBodyParts = []
                    }
                }

                if selectedFilterType == .category {
                    VStack(alignment: .leading) {
                        Text("Enter Category:")
                            .font(.headline)
                        TextField("E.g., Fitness, Strength", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                } else if selectedFilterType == .bodyParts {
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
                                            .font(.caption)
                                            .background(selectedBodyParts.contains(bodyPart) ? Color.accentColor : Color.gray.opacity(0.7))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .frame(height: 50) // Give ScrollView a defined height
                    }
                } else { // .none filter type
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

                    VStack(alignment: .leading) {
                        Text(selectedSearchType == .findById ? "Enter \(selectedContentType.rawValue) ID:" : "Enter \(selectedContentType.rawValue) Title:")
                            .font(.headline)
                        TextField(selectedSearchType == .findById ? "Enter ID" : "Enter Title", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }

                // Search Button
                Button(action: fetchData) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity, minHeight: 22) // Ensure button height
                    } else {
                        Text("Fetch \(selectedContentType.rawValue)")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isLoading || isSearchButtonDisabled())
                .padding()
                .background(isSearchButtonDisabled() ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("KinesteX API Demo")
            .sheet(isPresented: $presentDataView) {
                DataDisplayView(
                    workout: fetchedWorkout,
                    workouts: fetchedWorkouts,
                    exercise: fetchedExercise,
                    exercises: fetchedExercises,
                    plan: fetchedPlan,
                    plans: fetchedPlans,
                    contentType: selectedContentType.rawValue
                )
            }
            .alert("API Info", isPresented: $showAlert) { // Changed title from "Error"
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    func isSearchButtonDisabled() -> Bool {
        if isLoading { return true }
        switch selectedFilterType {
        case .none, .category:
            return searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .bodyParts:
            return selectedBodyParts.isEmpty
        }
    }

    func fetchData() {
        // Validation
        if selectedFilterType == .none && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "\(selectedSearchType == .findById ? "ID" : "Title") cannot be empty."
            showAlert = true
            return
        } else if selectedFilterType == .category && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Category cannot be empty."
            showAlert = true
            return
        } else if selectedFilterType == .bodyParts && selectedBodyParts.isEmpty {
            alertMessage = "Please select at least one body part."
            showAlert = true
            return
        }

        // Reset previous results
        fetchedWorkout = nil; fetchedWorkouts = nil
        fetchedExercise = nil; fetchedExercises = nil
        fetchedPlan = nil; fetchedPlans = nil
        isLoading = true

        Task {
            if selectedFilterType == .none {
                if selectedSearchType == .findById {
                    switch selectedContentType {
                    case .workout:
                        let result = await kinesteXKit.fetchWorkout(id: searchText)
                        handleSingleResult(result, &fetchedWorkout)
                    case .exercise:
                        let result = await kinesteXKit.fetchExercise(id: searchText)
                        handleSingleResult(result, &fetchedExercise)
                    case .plan:
                        let result = await kinesteXKit.fetchPlan(id: searchText)
                        handleSingleResult(result, &fetchedPlan)
                    }
                } else { // Find by Title - use general fetchContent
                    let apiResult = await kinesteXKit.fetchContent(
                        contentType: selectedContentType,
                        title: searchText,
                        limit: 10 // Fetch a list, API might return multiple
                    )
                    handleAPIContentResult(apiResult)
                }
            } else if selectedFilterType == .category {
                switch selectedContentType {
                case .workout:
                    let result = await kinesteXKit.fetchWorkouts(category: searchText, limit: 10)
                    handleListResult(result, for: &fetchedWorkouts) { $0.workouts }
                case .plan:
                    let result = await kinesteXKit.fetchPlans(category: searchText, limit: 10)
                    handleListResult(result, for: &fetchedPlans) { $0.plans }
                case .exercise:
                    // Exercises don't have a direct category filter in helper methods.
                    // Using fetchContent. Note: API docs state category is for workouts/plans.
                    // This might return an error or empty if not supported by API for exercises.
                    alertMessage = "Fetching exercises by category might not be supported. Using general content fetch."
                    showAlert = true // Inform user
                    let apiResult = await kinesteXKit.fetchContent(contentType: .exercise, category: searchText, limit: 10)
                    handleAPIContentResult(apiResult)
                }
            } else if selectedFilterType == .bodyParts {
                let bodyPartsArray = Array(selectedBodyParts)
                switch selectedContentType {
                case .workout:
                    let result = await kinesteXKit.fetchWorkouts(bodyParts: bodyPartsArray, limit: 10)
                    handleListResult(result, for: &fetchedWorkouts) { $0.workouts }
                case .exercise:
                    let result = await kinesteXKit.fetchExercises(bodyParts: bodyPartsArray, limit: 10)
                    handleListResult(result, for: &fetchedExercises) { $0.exercises }
                case .plan:
                    // Plans don't have bodyParts filter in fetchPlans helper. Using fetchContent.
                    let apiResult = await kinesteXKit.fetchContent(contentType: .plan, bodyParts: bodyPartsArray, limit: 10)
                    handleAPIContentResult(apiResult)
                }
            }

            isLoading = false
            // Determine if data view should be presented
            if !showAlert && (fetchedWorkout != nil || fetchedExercise != nil || fetchedPlan != nil ||
               (fetchedWorkouts?.isEmpty == false) ||
               (fetchedExercises?.isEmpty == false) ||
               (fetchedPlans?.isEmpty == false)) {
                presentDataView = true
            } else if !showAlert { // No data and no error alert shown yet
                alertMessage = "No results found for your criteria."
                showAlert = true
            }
        }
    }

    // Helper to handle results for single item fetches
    func handleSingleResult<T>(_ result: Result<T, Error>, _ modelStorage: inout T?) {
        switch result {
        case .success(let model):
            modelStorage = model
        case .failure(let error):
            alertMessage = "Error: \(error.localizedDescription)"
            showAlert = true
        }
    }

    // Helper to handle results for list item fetches from helper methods
    func handleListResult<ResponseType, ItemType>(
        _ result: Result<ResponseType, Error>,
        for listStorage: inout [ItemType]?,
        itemsExtractor: (ResponseType) -> [ItemType]
    ) {
        switch result {
        case .success(let response):
            listStorage = itemsExtractor(response)
            if listStorage?.isEmpty ?? true {
                 // This will be caught by the "No results found" logic later if no error
            }
        case .failure(let error):
            alertMessage = "Error: \(error.localizedDescription)"
            showAlert = true
        }
    }

    // Helper to handle APIContentResult from fetchContent
    func handleAPIContentResult(_ result: APIContentResult) {
        switch result {
        case .workout(let workout): fetchedWorkout = workout
        case .workouts(let response): fetchedWorkouts = response.workouts
        case .plan(let plan): fetchedPlan = plan
        case .plans(let response): fetchedPlans = response.plans
        case .exercise(let exercise): fetchedExercise = exercise
        case .exercises(let response): fetchedExercises = response.exercises
        case .error(let message):
            alertMessage = "API Error: \(message)"
            showAlert = true
        case .rawData(let dict, let optMessage):
            alertMessage = "Received raw data (parsing may have failed): \(optMessage ?? "No details"). Data: \(dict.description.prefix(200))..."
            showAlert = true
        }
        if (fetchedWorkouts?.isEmpty ?? false) && selectedContentType == .workout && fetchedWorkout == nil { fetchedWorkouts = nil }
        if (fetchedExercises?.isEmpty ?? false) && selectedContentType == .exercise && fetchedExercise == nil { fetchedExercises = nil }
        if (fetchedPlans?.isEmpty ?? false) && selectedContentType == .plan && fetchedPlan == nil { fetchedPlans = nil }
    }
}

// Simple Data Display View for the sheet
struct DataDisplayView: View {
    let workout: WorkoutModel?
    let workouts: [WorkoutModel]?
    let exercise: ExerciseModel?
    let exercises: [ExerciseModel]?
    let plan: PlanModel?
    let plans: [PlanModel]?
    let contentType: String

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if let item = workout {
                        SectionView(title: "Fetched Workout (Single)", items: [item]) { "\($0.title) (ID: \($0.id)) \nDesc: \($0.description.prefix(100))..." }
                    }
                    if let items = workouts, !items.isEmpty {
                        SectionView(title: "Fetched Workouts (List)", items: items) { "\($0.title) (ID: \($0.id))" }
                    }
                    if let item = exercise {
                        SectionView(title: "Fetched Exercise (Single)", items: [item]) { "\($0.title) (ID: \($0.id)) \nDesc: \($0.description.prefix(100))..." }
                    }
                    if let items = exercises, !items.isEmpty {
                        SectionView(title: "Fetched Exercises (List)", items: items) { "\($0.title) (ID: \($0.id))" }
                    }
                    if let item = plan {
                        SectionView(title: "Fetched Plan (Single)", items: [item]) { "\($0.title) (ID: \($0.id)) \nCategory: \(item.category.description.prefix(100))..." }
                    }
                    if let items = plans, !items.isEmpty {
                        SectionView(title: "Fetched Plans (List)", items: items) { "\($0.title) (ID: \($0.id))" }
                    }

                    if workout == nil && workouts?.isEmpty ?? true &&
                       exercise == nil && exercises?.isEmpty ?? true &&
                       plan == nil && plans?.isEmpty ?? true {
                        Text("No specific \(contentType) data to display, or the list is empty.")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("\(contentType) Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // How to dismiss? This view is presented by a sheet.
                        // The sheet's isPresented binding will handle dismissal.
                        // This button is good for clarity.
                        // To make it functional, pass down the binding or use @Environment.
                    }
                }
            }
        }
    }
}

struct SectionView<Item: Identifiable>: View {
    let title: String
    let items: [Item]
    let content: (Item) -> String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            ForEach(items) { item in
                Text(content(item))
                    .padding(.vertical, 2)
                Divider()
            }
        }
    }
}

#Preview {
    APIDemoView()
}
```