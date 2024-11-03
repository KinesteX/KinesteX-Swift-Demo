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
                    .font(.headline)
                
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
                        await KinesteXAIFramework.fetchAPIContentData(apiKey: apiKey, companyName: company,contentType: selectedContentType, id: selectedSearchType == .findById ? searchText : nil, title: selectedSearchType == .findByTitle ? searchText : nil) { result in
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
                        if fetchedWorkout != nil {
                            presentDataView = true
                        } else if fetchedExercise != nil {
                            presentDataView = true
                        } else if fetchedPlan != nil {
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
    
    // MARK: - Network Request Function

}

struct APIDemoView_Previews: PreviewProvider {
    static var previews: some View {
        APIDemoView()
    }
}
