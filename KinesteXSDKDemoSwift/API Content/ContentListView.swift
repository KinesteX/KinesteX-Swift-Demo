//
//  ContentListView.swift
//  KinesteXSDKDemoSwift
//
//  Created by Vladimir Shetnikov on 11/9/24.
//

import SwiftUI
import KinesteXAIKit

struct ContentListView: View {
    let workouts: [WorkoutModel]?
    let exercises: [ExerciseModel]?
    let plans: [PlanModel]?
    let contentType: ContentType
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                if let workouts = workouts {
                    ForEach(workouts, id: \.id) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            ContentCardView(
                                title: workout.title,
                                imageURL: workout.imgURL,
                                contentType: .workout
                            )
                        }
                    }
                } else if let exercises = exercises {
                    ForEach(exercises, id: \.id) { exercise in
                        NavigationLink(destination: ExerciseCardView(exercise: exercise, index: 0)) {
                            ContentCardView(
                                title: exercise.title,
                                imageURL: exercise.thumbnailURL,
                                contentType: .exercise
                            )
                        }
                    }
                } else if let plans = plans {
                    ForEach(plans, id: \.id) { plan in
                        NavigationLink(destination: PlanDetailView(plan: plan)) {
                            ContentCardView(
                                title: plan.title,
                                imageURL: plan.imgURL,
                                contentType: .plan
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("\(contentType.rawValue)s")
    }
}

// Reusable card view for content items
struct ContentCardView: View {
    let title: String
    let imageURL: String
    let contentType: ContentType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(8)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
