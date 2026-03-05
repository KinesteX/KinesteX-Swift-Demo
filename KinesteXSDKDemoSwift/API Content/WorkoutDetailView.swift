import SwiftUI
import KinesteXAIKit
struct WorkoutDetailView: View {
    let workout: WorkoutModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Workout Image
                AsyncImage(url: URL(string: workout.imgURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Workout Title
                Text(workout.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Workout Description
                Text(workout.description)
                    .font(.body)
                
                // Workout Details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category:")
                            .fontWeight(.semibold)
                        Text(workout.category ?? "N/A")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration:")
                            .fontWeight(.semibold)
                        Text("\(workout.totalMinutes ?? 0) minutes")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calories:")
                            .fontWeight(.semibold)
                        Text("\(workout.totalCalories ?? 0) kcal")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Body Parts
                VStack(alignment: .leading, spacing: 8) {
                    Text("Targeted Body Parts:")
                        .font(.headline)
                    
                    WrapView(items: workout.bodyParts, spacing: 8, alignment: .leading) { part in
                        Text(part)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Equipment
                if !workout.equipment.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Equipment:")
                            .font(.headline)

                        ForEach(workout.equipment) { item in
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: item.thumbnailURL)) { image in
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title).font(.subheadline).bold()
                                    Text(item.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    if !item.homeAlternative.isEmpty {
                                        Text("Home: \(item.homeAlternative)")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Divider()

                // Exercises Sequence
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise Sequence:")
                        .font(.headline)
                    
                    ForEach(workout.sequence.indices, id: \.self) { index in
                        let exercise = workout.sequence[index]
                        ExerciseCardView(exercise: exercise, index: index + 1)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
}

