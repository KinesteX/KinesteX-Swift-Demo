//
//  ContentView.swift
//  KinesteXSDKDemoSwift
//
//  Created by Vladimir Shetnikov on 6/2/24.
//

import SwiftUI
import KinesteXAIKit

struct ExerciseStep {
    let modelId: String
    let restSpeechId: String
    let displayName: String // For UI display if needed
}

struct ContentView: View {
    @State var showKinesteX = false
    @State var showExplanation = false
    @State var isLoading = true
    @State var isExpanded = false
    @State var isExpandedInner = false
    let kinestex = KinesteXAIKit(apiKey: "your_api_key", companyName: "your_company_name", userId: "your_user_id")
    @State var selectedWorkout = "Fitness Lite"
    @State var selectedChallenge = "Squats"
    @State var selectedExperience = "Box"
    
//    let recommendedChallenges = [
//        "Squats",
//        "Jumping Jack",
//        "Burpee",
//        "Push Ups",
//        "Lunges",
//    ]

// custom workout parameters
    @State var workoutAction: [String: Any]? = nil // we will send workout start action to launch the phone orientation check
    @State var customWorkoutReady = false
    
    // workout config, consists of exercise elements 
    let customWorkoutExercises: [WorkoutSequenceExercise] = [
        WorkoutSequenceExercise(
            exerciseId: "jz73VFlUyZ9nyd64OjRb",
            reps: 15,
            duration: nil,
            includeRestPeriod: true,
            restDuration: 20
        ),
        WorkoutSequenceExercise(
            exerciseId: "ZVMeLsaXQ9Tzr5JYXg29",
            reps: 10,
            duration: 30,
            includeRestPeriod: true,
            restDuration: 15
        ),
        WorkoutSequenceExercise(
            exerciseId: "gJGOiZhCvJrhEP7sTy78",
            reps: 20,
            duration: nil,
            includeRestPeriod: false,
            restDuration: 0
        )
    ]
    
    @State var selectedPlan = "YFC Plan"
    @State var selectedOption = "Complete UX"
    @State var planCategory: PlanCategory = .Cardio
    
    var user = UserDetails(age: 20, height: 170, weight: 70, gender: .Male, lifestyle: .Active)
    
    // for camera component
    @State var reps = 0
    @State var maxAccuracy: Double = 0
    @State var currentAccuracy: Double = 0
    // Use the model ID for the initial exercise
    
    let workoutSequence: [ExerciseStep] = [
         ExerciseStep(
             modelId: "FnVw8iNoh9CoNzRtMTVN",
             restSpeechId: "get-ready-for-squats-stand-tall-feet-sho-950620fb49c662491f175fceac3a6e26e90c1081",
             displayName: "Squats"
         ),
         ExerciseStep(
             modelId: "ybdSQyx3FKOuOO617R1v",
             restSpeechId: "start-standing-tall-feet-together-arms-b-bd694fd3d8af1e56f940aadcc9d853d42466b3c0",
             displayName: "Jumping Jacks"
         ),
     ]
    
    // ADD a state to track our position in the sequence (rest/exercise)
      @State private var sequenceIndex = 0
    @State var currentExercise = "Pause Exercise"
    @State var currentRestSpeech: String? = nil
    
    // Add these two functions inside your ContentView struct

    private func updateStateForCurrentIndex() {
        // An even index is a REST step, an odd index is an EXERCISE step
        if sequenceIndex % 2 == 0 { // This is a REST step
            let exerciseIndex = sequenceIndex / 2
            // Ensure we are not at the very end of the workout
            if exerciseIndex < workoutSequence.count {
                currentExercise = "Pause Exercise"
                currentRestSpeech = workoutSequence[exerciseIndex].restSpeechId
            }
        } else { // This is an EXERCISE step
            let exerciseIndex = (sequenceIndex - 1) / 2
            if exerciseIndex < workoutSequence.count {
                currentExercise = workoutSequence[exerciseIndex].modelId
                currentRestSpeech = nil // No rest speech during an exercise
            }
        }

        // Reset stats every time we change step
        reps = 0
        maxAccuracy = 0
        mistake = ""
        currentAccuracy = 0
    }

    private func cycleStep(forward: Bool) {
        // Total steps = (number of exercises * 2)
        // e.g., 2 exercises = 4 steps (Rest, Ex1, Rest, Ex2)
        // Max index is total steps - 1
        let maxIndex = workoutSequence.count * 2 - 1
        var newIndex = sequenceIndex

        if forward {
            newIndex += 1
        } else {
            newIndex -= 1
        }

        // Boundary check to prevent going out of range
        if newIndex >= 0 && newIndex <= maxIndex {
            sequenceIndex = newIndex
            updateStateForCurrentIndex()
        }
    }
    
    @State var mistake = ""
    @State var personInFrame = false

    @ViewBuilder
    var mainContent: some View {
   
        DisclosureGroup("Select Integration Option", isExpanded: $isExpanded) {
            content
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    @ViewBuilder
    var workoutPlanCustomization: some View {
   
        DisclosureGroup("Select Plan", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Full Cardio", isSelected: selectedPlan == "Full Cardio", action: {
                    selectedPlan = "Full Cardio"
 
                })
                RadioButton(title: "Elastic Evolution", isSelected: selectedPlan == "Elastic Evolution", action: {
                    selectedPlan = "Elastic Evolution"
                })
                RadioButton(title: "Circuit Training", isSelected: selectedPlan == "Circuit Training", action: {
                    selectedPlan = "Circuit Training"
                })
                RadioButton(title: "Fitness Cardio", isSelected: selectedPlan == "Fitness Cardio", action: {
                    selectedPlan = "Fitness Cardio"
                })
                // all of other available plans. Please contact KinesteX to get access to the list of available plans and workouts
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    var mainCustomization: some View {
   
        DisclosureGroup("Select Goal Category", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Cardio", isSelected: planCategory == .Cardio, action: {
                    planCategory = .Cardio
 
                })
                RadioButton(title: "Strength", isSelected: planCategory == .Strength, action: {
                    planCategory = .Strength
                })
                RadioButton(title: "Weight Management", isSelected: planCategory == .WeightManagement, action: {
                    planCategory = .WeightManagement
                })
                RadioButton(title: "Rehabilitation", isSelected: planCategory == .Rehabilitation, action: {
                    planCategory = .Rehabilitation
                })
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    var workoutCustomization: some View {
   
        DisclosureGroup("Select Workout", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Fitness Lite", isSelected: selectedWorkout == "Fitness Lite", action: {
                    selectedWorkout = "Fitness Lite"
 
                })
                RadioButton(title: "Circuit Training", isSelected: selectedWorkout == "Circuit Training", action: {
                    selectedWorkout = "Circuit Training"
                })
                RadioButton(title: "Tabata", isSelected: selectedWorkout == "Tabata", action: {
                   selectedWorkout = "Tabata"
                })
                
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    @ViewBuilder
    var experienceCustomization: some View {
   
        DisclosureGroup("Select Experience", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Box", isSelected: selectedExperience == "Box", action: {
                    selectedExperience = "Box"
 
                })
             
                
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    
    @ViewBuilder
    var challengeCustomization: some View {
   
        DisclosureGroup("Select Challenge", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Squats", isSelected: selectedChallenge == "Squats", action: {
                    selectedChallenge = "Squats"
 
                })
                RadioButton(title: "Jumping Jack", isSelected: selectedChallenge == "Jumping Jack", action: {
                    selectedChallenge = "Jumping Jack"
                })
           
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    var content: some View {
   
        VStack {
            RadioButton(title: "Complete UX", isSelected: selectedOption == "Complete UX", action: {
                selectedOption = "Complete UX"
            })
            RadioButton(title: "Workout Plan", isSelected: selectedOption == "Plan", action: {
                selectedOption = "Plan"
            })
            RadioButton(title: "Workout", isSelected: selectedOption == "Workout", action: {
                selectedOption = "Workout"
            })
            RadioButton(title: "Challenge", isSelected: selectedOption == "Challenge", action: {
                selectedOption = "Challenge"
            })
            RadioButton(title: "Experience", isSelected: selectedOption == "Experience", action: {
                selectedOption = "Experience"
            })
            RadioButton(title: "Leaderboard", isSelected: selectedOption == "Leaderboard", action: {
                selectedOption = "Leaderboard"
            })
            RadioButton(title: "Camera", isSelected: selectedOption == "Camera", action: {
                selectedOption = "Camera"
            })
            
            RadioButton(title: "Custom Workout", isSelected: selectedOption == "Custom Workout", action: {
                selectedOption = "Custom Workout"
            })
            RadioButton(title: "Admin Editor", isSelected: selectedOption == "Admin Editor", action: {
                selectedOption = "Admin Editor"
            })
        }
        
    }
    
    @ViewBuilder
    var kinestexView: some View {
   
        if selectedOption == "Complete UX" {
            kinestex.createCategoryView(planCategory: planCategory, user: nil, style: nil, isLoading: $isLoading, customParams: ["style": "light"], onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        break
                    }
            })
        } else if selectedOption == "Plan" {
            kinestex.createPlanView(plan: selectedPlan, user: nil, style: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        break
                    }
            })
        } else if selectedOption == "Workout" {
            kinestex.createPersonalizedPlanView(user: nil, style: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        print("received message: ", message)
                        break
                    }
            })
        } else if selectedOption == "Challenge" {
            kinestex.createChallengeView(exercise: selectedChallenge, duration: 100, user: nil, style: nil, isLoading: $isLoading, customParams: ["style": "dark"], onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        break
                    }
            })
        } else if selectedOption == "Experience" {
            kinestex.createExperienceView(experience: "box", exercise: "Boxing", user: nil, style: nil, isLoading: $isLoading, onMessageReceived: {
                message in
                switch message {
                case .exit_kinestex(_):
                   showKinesteX = false
                    break
               // handle all other cases accordingly
                default:
                    break
                }
            })
        }
        else if selectedOption == "Leaderboard" {
            kinestex.createLeaderboardView(
              exercise: "Squats", // Specify the exercise ID or title
              username: "", // if you know the username a person has entered: you can highlight the user by specifying their username
              style: nil,
              isLoading: $isLoading,
              customParams: [
                "style": "dark", // light or dark theme (default is dark)
                "isHideHeaderMain": true, // OPTIONAL: hide the exit button from the leaderboard
              ],
              onMessageReceived: {
                    message in
                        switch message {
                            case .exit_kinestex(_):
                               showKinesteX = false
                                break
                           // handle all other cases accordingly
                            default:
                                break
                }
            })
        }
        else if selectedOption == "Custom Workout" {
            kinestex.createCustomWorkoutView(
                exercises: customWorkoutExercises,
                user: user,
                style: nil,
                isLoading: $isLoading,
                workoutAction: $workoutAction,
                customParams: ["style": "dark"],
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false
                        customWorkoutReady = false
                    case .custom_type(let value):
                        guard let receivedType = value["type"] as? String else { return }
                        
                        if receivedType == "all_resources_loaded" {
                            print("All resources loaded - starting workout")
                            customWorkoutReady = true
                            // Send start action
                            workoutAction = [
                                "workout_activity_action": "start"
                            ]
                        } else if receivedType == "workout_exit_request" {
                            showKinesteX = false
                        }
                    case .error_occurred(let value):
                        print("Error: \(value)")
                    case .workout_completed(let value):
                        print("Workout completed: \(value)")
                        showKinesteX = false
                    default:
                        print("Custom Workout message: \(message)")
                    }
                }
            )
        }
        else if selectedOption == "Admin Editor" {
            kinestex.createAdminWorkoutEditor(
                organization: "YourOrganization", // Replace with your organization name
                contentType: nil, // Optional: .workout, .plan, or .exercise
                contentId: nil,   // Optional: specific content ID to edit
                customQueries: nil, // Optional: additional query parameters
                isLoading: $isLoading,
                customParams: [:],
                onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false
                    case .custom_type(let value):
                        print("Admin Editor message: \(value)")
                    default:
                        print("Admin message: \(message)")
                    }
                }
            )
        }
        else {
            ZStack {
                kinestex.createCameraView(
                    exercises: workoutSequence.map { $0.modelId },
                    currentExercise: $currentExercise,
                    currentRestSpeech: $currentRestSpeech,
                    user: nil,
                    style: nil,
                    isLoading: $isLoading,
                    customParams: [
                        // Pass all rest speeches that will be used
                        "restSpeeches": workoutSequence.map { $0.restSpeechId },
                        "includePoseBorders": false
                    ],
                    onMessageReceived: { message in
                        switch message {
                        case .reps(let value):
                            reps = value["value"] as? Int ?? 0
                            maxAccuracy = value["accuracy"] as? Double ?? 0
                            break
                        case .mistake(let value):
                            mistake = value["value"] as? String ?? "--"
                            break
                        case .custom_type(let value):
                            guard let received_type = value["type"] else {
                                return
                            }
                            if (received_type as! String == "models_loaded") {
                                print("All models loaded")
                            } else if (received_type as! String
                                       == "person_in_frame")
                            {
                                withAnimation {
                                    personInFrame = true
                                }
                            } else if (received_type as! String
                                       == "correct_position_accuracy")
                            {
                                currentAccuracy =
                                value["accuracy"] as? Double ?? 0
                            }
                        default:
                            break
                        }
                    }
                )
                .frame(
                    width: personInFrame ? 100 : UIScreen.main.bounds.width,
                    height: personInFrame ? 200 : UIScreen.main.bounds.height
                )
                .cornerRadius(personInFrame ? 10 : 0)
                .padding(personInFrame ? 8 : 0)
                
                if personInFrame {
                    VStack {
                        Text("REPS: \(reps)")
                            .padding(4)
                            .font(.title)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        Text("\(maxAccuracy)%")
                            .padding(4)
                            .font(.title)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.green)
                            .cornerRadius(5)
                        Text("MISTAKE: \(mistake)")
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.red)
                            .cornerRadius(5)
                        Text("Current A: \(currentAccuracy)%")
                            .padding(4)
                            .font(.title)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.green)
                            .cornerRadius(5)
                    }
                    .padding(12)
                } else {
                    VStack {
                        Text("REPS: \(reps)")
                        Text("MISTAKE: \(mistake)").foregroundColor(.red)
                        Spacer()
                    }
                }
                
                VStack {
                    Spacer() // Pushes the buttons to the bottom
                    HStack(spacing: 20) {
                        // Previous Button
                        Button(action: {
                            cycleStep(forward: false)
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        // Disable button if at the very first step
                        .disabled(sequenceIndex == 0)
                        
                        // Next Button
                        Button(action: {
                            cycleStep(forward: true)
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        // Disable button if at the very last step
                        .disabled(sequenceIndex >= workoutSequence.count * 2 - 1)
                    }
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                // When the view appears, set up the initial state for the
                // first rest period.
                sequenceIndex = 0
                updateStateForCurrentIndex()
            }
        
        }
        
    }
    var body: some View {
        
        if showExplanation {
            NavigationView {
                            ZStack {
                                if #available(iOS 14, *) {
                                    kinestex.createHowToView(videoURL: "https://cdn.kinestex.com/SDK%2Fhow-to-video%2Ffinal%20light%20theme.mp4?alt=media&token=a0284982-f17b-4415-b109-36a7c623f982") {
                                        showExplanation.toggle()
                                    }
                                   
                                }

                            }
                            .navigationBarTitle("How it works", displayMode: .inline) // Custom title for the video view
                            .navigationBarItems(leading: Button(action: {
                                showExplanation.toggle() // Toggle back to the previous view
                            }) {
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            })
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
         
        } else if showKinesteX {
              kinestexView.frame(maxWidth: .infinity, maxHeight: .infinity) // Fullscreen
                   
            } else {
                VStack{
                    Spacer()
                
                    mainContent
                    if selectedOption == "Complete UX" {
                        mainCustomization
                    } else if selectedOption == "Plan" {
                        workoutPlanCustomization
                    } else if selectedOption == "Workout" {
                        workoutCustomization
                    } else if selectedOption == "Challenge" {
                        challengeCustomization
                    } else if selectedOption == "Experience"{
                        experienceCustomization
                    }
                    Button(action: {
                        showExplanation.toggle()
                    }) {
                        Text("Play Explanation Video")
                    }
                    Spacer()
                    
                    Button(action: {
                        showKinesteX = true
                       
                    }, label: {
                        Text("View \(selectedOption)").font(.title3).foregroundColor(.white).bold().padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.cornerRadius(10))
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                    }).padding(.bottom, 30)
                    
                }.ignoresSafeArea().background(.black)
            }
            
            
        
       
    }
}

#Preview {
    ContentView()
}
