//
//  WorkoutRoutineView.swift
//  KinesteXSDKDemoSwift
//
//  Created on 2/24/26.
//

import SwiftUI

// MARK: - Grouped Exercise Model

struct GroupedExercise: Identifiable {
    let id = UUID()
    let index: Int
    let title: String
    let exerciseId: String
    let reps: Int?
    let duration: Int? // seconds
    let restDuration: Int?
    let setCount: Int
}

// MARK: - Grouping Logic

func groupExercises(_ exercises: [WorkoutExerciseItem]) -> [GroupedExercise] {
    guard !exercises.isEmpty else { return [] }

    var groups: [GroupedExercise] = []
    var i = 0
    var groupIndex = 1

    while i < exercises.count {
        let current = exercises[i]
        var count = 1

        // Look ahead for consecutive exercises with the same id
        var j = i + 1
        while j < exercises.count && exercises[j].exerciseId == current.exerciseId {
            count += 1
            j += 1
        }

        groups.append(GroupedExercise(
            index: groupIndex,
            title: current.title,
            exerciseId: current.exerciseId,
            reps: current.reps,
            duration: current.countdown,
            restDuration: current.restDuration,
            setCount: count
        ))

        groupIndex += 1
        i = j
    }
    return groups
}

// MARK: - Duration Formatter

private func formatDuration(_ seconds: Int) -> String {
    if seconds >= 60 && seconds % 60 == 0 {
        return "\(seconds / 60) min"
    } else if seconds >= 60 {
        return "\(seconds / 60)m \(seconds % 60)s"
    } else {
        return "\(seconds) sec"
    }
}

// MARK: - Workout Routine View

struct WorkoutRoutineView: View {
    let title: String
    let totalMinutes: Int?
    let difficultyLevel: String?
    let exercises: [WorkoutExerciseItem]
    let onStart: () -> Void

    var body: some View {
        let groups = groupExercises(exercises)

        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    HStack(spacing: 6) {
                        if let mins = totalMinutes {
                            Text("\(mins) min")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        if let diff = difficultyLevel {
                            Text(diff)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
                Button(action: onStart) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                        Text("Start")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 6)

            // Divider with "ROUTINE" label
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                Text("ROUTINE")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)

            // Exercise list
            ForEach(groups) { group in
                ExerciseRow(group: group)
            }
            .padding(.bottom, 6)
        }
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Exercise Row

private struct ExerciseRow: View {
    let group: GroupedExercise

    var body: some View {
        HStack(spacing: 8) {
            // Index badge
            Text("\(group.index)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .frame(width: 22, height: 22)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(5)

            // Title
            Text(group.title)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            // Reps / Duration + set count
            Text(detailText)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 12)
    }

    private var detailText: String {
        var base: String
        if let reps = group.reps, reps > 0 {
            base = "\(reps) reps"
        } else if let dur = group.duration, dur > 0 {
            base = formatDuration(dur)
        } else if let rest = group.restDuration, rest > 0 {
            base = formatDuration(rest)
        } else {
            base = ""
        }

        if group.setCount > 1 {
            base += " \u{00d7} \(group.setCount)"
        }
        return base
    }
}
