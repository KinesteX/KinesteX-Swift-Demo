//
//  ContentView.swift
//  KinesteXSDKDemoSwift
//
//  Created by Vladimir Shetnikov on 6/2/24.
//
import KinesteXAIFramework
import SwiftUI

struct ContentView: View {
    @State var showKinesteX = false
    @State var isLoading = false
    @State var isExpanded = false
    @State var isExpandedInner = false

    let apiKey = "" // store this key securely
    let company = ""
    @State var selectedWorkout = "Fitness Lite"
    @State var selectedChallenge = "Squats"
    @State var selectedPlan = "Full Cardio"
    @State var selectedOption = "Complete UX"
    @State var planCategory: PlanCategory = .Cardio
    // for camera component
    @State var reps = 0
    @State var mistake = ""

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
            RadioButton(title: "Camera", isSelected: selectedOption == "Camera", action: {
                selectedOption = "Camera"
            })
        }
        
    }
    
    @ViewBuilder
    var kinestexView: some View {
   
        if selectedOption == "Complete UX" {
            KinesteXAIFramework.createMainView(apiKey: apiKey, companyName: company, userId: "user1", planCategory: planCategory, user: nil, isLoading: $isLoading, onMessageReceived: {
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
            KinesteXAIFramework.createPlanView(apiKey: apiKey, companyName: company, userId: "user1", planName: selectedPlan, user: nil, isLoading: $isLoading, onMessageReceived: {
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
            KinesteXAIFramework.createWorkoutView(apiKey: apiKey, companyName: company, userId: "user1", workoutName: selectedWorkout, user: nil, isLoading: $isLoading, onMessageReceived: {
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
        } else if selectedOption == "Challenge" {
            KinesteXAIFramework.createChallengeView(apiKey: apiKey, companyName: company, userId: "user1", exercise: selectedChallenge, countdown: 100, user: nil, isLoading: $isLoading, onMessageReceived: {
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
        } else {
            ZStack {
                KinesteXAIFramework.createCameraComponent(apiKey: apiKey, companyName: company, userId: "user1", exercises: ["Squats"], currentExercise: "Squats", user: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false
                        break
                    case .reps(let value):
                        reps = value["value"] as? Int ?? 0
                        break
                    case .mistake(let value):
                        mistake = value["value"] as? String ?? "--"
                        break
                        // handle all other cases accordingly
                    default:
                        break
                    }
                })
                VStack {
                    Text("REPS: \(reps)")
                    Text("MISTAKE: \(mistake)").foregroundColor(.red)
                    Spacer()
                   
                }
            }
        }
        
    }
    var body: some View {
  
            if showKinesteX {
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
                    } else {
                        
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
