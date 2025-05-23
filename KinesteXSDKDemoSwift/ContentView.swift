//
//  ContentView.swift
//  KinesteXSDKDemoSwift
//
//  Created by Vladimir Shetnikov on 6/2/24.
//

import SwiftUI
import KinesteXAIKit

struct ContentView: View {
    @State var showKinesteX = false
    @State var showExplanation = false
    @State var isLoading = true
    @State var isExpanded = false
    @State var isExpandedInner = false
    let kinestex = KinesteXAIKit(apiKey: "YOUR_API_KEY", companyName: "YOUR_COMPANY_NAME", userId: "YOUR_USER_ID")
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

    
    @State var selectedPlan = "Full Cardio"
    @State var selectedOption = "Complete UX"
    @State var planCategory: PlanCategory = .Cardio
    
    var user = UserDetails(age: 20, height: 170, weight: 70, gender: .Male, lifestyle: .Active)
    
    // for camera component
    @State var reps = 0
    @State var maxAccuracy: Double = 0
    @State var currentAccuracy: Double = 0
    @State var currentExercise = "Squats" // model ID or exercise title
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
        }
        
    }
    
    @ViewBuilder
    var kinestexView: some View {
   
        if selectedOption == "Complete UX" {
            kinestex.createCategoryView(planCategory: planCategory, user: nil, isLoading: $isLoading, customParams: ["style": "light"], onMessageReceived: {
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
            kinestex.createPlanView(plan: selectedPlan, user: nil, isLoading: $isLoading, onMessageReceived: {
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
            kinestex.createWorkoutView(workout: selectedWorkout, user: nil, isLoading: $isLoading, onMessageReceived: {
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
            kinestex.createChallengeView(exercise: selectedChallenge, duration: 100, user: nil, isLoading: $isLoading, customParams: ["style": "dark"], onMessageReceived: {
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
            kinestex.createExperienceView(experience: "box", exercise: "Boxing", user: nil, isLoading: $isLoading, onMessageReceived: {
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
        else {
            ZStack(alignment: .topTrailing) { // Changed to topTrailing alignment
                kinestex.createCameraView(exercises: ["Squats", "Jumping Jack"], currentExercise: $currentExercise, user: nil, isLoading: $isLoading, onMessageReceived: {
                              message in
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
                                  } else if (received_type as! String == "person_in_frame") {
                                      withAnimation {
                                          personInFrame = true
                                      }
                                  } else if (received_type as! String == "correct_position_accuracy") {
                                      currentAccuracy = value["accuracy"] as? Double ?? 0
                                  }
                              default:
                                  break
                              }
                          })
                           // resize the frame to display exercise content accordingly
                          .frame(
                              width: personInFrame ? 100 : UIScreen.main.bounds.width,
                              height: personInFrame ? 200 : UIScreen.main.bounds.height
                          )
                          .cornerRadius(personInFrame ? 10 : 0) // Add rounded corners when minimized
                          .padding(personInFrame ? 8 : 0) // Add some padding when minimized
                          
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
