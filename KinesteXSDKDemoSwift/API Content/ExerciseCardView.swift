import SwiftUI
import AVKit
import KinesteXAIKit

struct ExerciseCardView: View {
    let exercise: ExerciseModel
    let index: Int
    @State private var showVideoPlayer = false
    @State private var maleVideoPlayer = false
    
    var body: some View {
        VStack {
            if let restDuration = exercise.restDuration {
                Text("Rest duration: \(restDuration) seconds")
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Exercise \(index): \(exercise.title)")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Difficulty Level Indicator
                    Text(exercise.difficultyLevel)
                        .font(.subheadline)
                        .padding(6)
                        .background(colorForDifficulty(exercise.difficultyLevel))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                Text("Model id: \(exercise.modelId)")
                // Exercise Thumbnail or Video Player
                if showVideoPlayer, let videoURL = URL(string: exercise.videoURL) {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .cornerRadius(10)
                } else {
                    AsyncImage(url: URL(string: exercise.thumbnailURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .clipped()
                                .cornerRadius(10)
                                .onTapGesture {
                                    showVideoPlayer.toggle()
                                }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                // Exercise Thumbnail or Video Player
                if maleVideoPlayer, let videoURL = URL(string: exercise.maleVideoURL) {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .cornerRadius(10)
                } else {
                    AsyncImage(url: URL(string: exercise.maleThumbnailURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .clipped()
                                .cornerRadius(10)
                                .onTapGesture {
                                    maleVideoPlayer.toggle()
                                }
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                if let reps = exercise.workoutReps ?? exercise.averageReps {
                    Text("Reps: \(reps)")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else if let countdown = exercise.workoutCountdown ?? exercise.averageCountdown {
                    Text("Countdown: \(countdown)")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                Text("Body Parts: \(exercise.bodyParts.joined(separator: ", "))").font(.caption)
                
                // Exercise Description
                Text(exercise.description)
                    .font(.body)
                
                // Steps
                VStack(alignment: .leading, spacing: 4) {
                    Text("Steps:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(exercise.steps, id: \.self) { step in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(step)
                        }
                        .font(.caption)
                    }
                }
                
                // Tips
                if !exercise.tips.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tips:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(exercise.tips)
                            .font(.caption)
                    }
                }
                
                // Common Mistakes
                if !exercise.commonMistakes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Common Mistakes:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(exercise.commonMistakes)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
        }
    }
    
    func colorForDifficulty(_ level: String) -> Color {
        switch level.lowercased() {
        case "easy":
            return Color.green
        case "medium":
            return Color.orange
        case "hard":
            return Color.red
        default:
            return Color.gray
        }
    }
}
