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

