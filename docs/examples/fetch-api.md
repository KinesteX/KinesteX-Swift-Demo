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