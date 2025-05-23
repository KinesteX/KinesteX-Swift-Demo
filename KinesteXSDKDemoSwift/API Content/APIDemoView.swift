import SwiftUI
import KinesteXAIKit

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
    @State private var selectedBodyParts: Set<BodyPart> = []

    // State variables
    @State private var selectedContentType: ContentType = .workout
    @State private var selectedFilterType:  FilterType = .none
    @State private var selectedSearchType: SearchType = .findById
    @State private var searchText: String = ""
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
    
    // initialize the SDK with apikey
    let kinestex = KinesteXAIKit(apiKey: "YOUR_API_KEY", companyName: "YOUR_COMPANY_NAME", userId: "YOUR_USER_ID")
    
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
                // Search Field
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
                // Show selectable buttons for BodyPart
                  VStack(alignment: .leading) {
                      Text("Select Body Parts:")
                          .font(.headline)
                      
                      // Use a ScrollView in case there are many body parts
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
            }
            else {
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
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedBodyParts.isEmpty {
                    alertMessage = "\(selectedSearchType == .findById ? "ID" : "Title") cannot be empty."
                    showAlert = true
                } else {
                    fetchedWorkout = nil
                    fetchedExercise = nil
                    fetchedPlan = nil
                    Task {
                        isLoading = true
                        // sending request based on what is selected in the UI
                        let result = await kinestex.fetchContent(contentType: selectedContentType,
                                                                      id: (selectedFilterType == .none && selectedSearchType == .findById) ? searchText : nil,
                                                                      title: (selectedFilterType == .none && selectedSearchType == .findByTitle) ? searchText : nil,
                                                                      category: selectedFilterType == .category ? searchText : nil,
                                                                 bodyParts: selectedFilterType == .bodyParts ? Array(selectedBodyParts) : nil)
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
                            print("Error:", errorMessage)
                            
                        default:
                            break
                        }
                        
                        isLoading = false
                        if fetchedWorkout != nil {
                            presentDataView = true
                        } else if fetchedExercise != nil {
                            presentDataView = true
                        } else if fetchedPlan != nil {
                            presentDataView = true
                        } else if fetchedWorkouts != nil {
                            presentDataView = true
                        } else if fetchedPlans != nil {
                            presentDataView = true
                        } else if fetchedExercises != nil {
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
            .disabled(isLoading || (searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedBodyParts.isEmpty))
            .padding()
            .frame(maxWidth: .infinity)
            .background((searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedBodyParts.isEmpty) ? Color.gray : Color.blue)
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
                        else {
                            ContentListView(workouts: fetchedWorkouts, exercises: fetchedExercises, plans: fetchedPlans, contentType: selectedContentType)
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
