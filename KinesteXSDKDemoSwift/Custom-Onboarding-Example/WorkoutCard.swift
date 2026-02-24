//
//  WorkoutCard.swift
//  KinesteXSDKDemoSwift
//
//  Created on 2/24/26.
//

import SwiftUI

struct WorkoutCard: View {
    let title: String
    let imageURL: String
    let calories: Int
    let minutes: Int
    let difficulty: String
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Workout image
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipped()
                    .cornerRadius(10)
            } placeholder: {
                Color.gray.opacity(0.3)
                    .frame(width: 90, height: 90)
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Text("\(calories) kcal")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("·")
                        .foregroundColor(.gray)
                    Text("\(minutes) minutes")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Button(action: onStart) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                        Text("Start")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                    )
                }
            }
        }
        .padding(10)
        .frame(width: 280, alignment: .leading)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
    }
}

// MARK: - Challenge Card

struct ChallengeCard: View {
    let title: String
    let calories: Int
    let duration: String
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 4) {
                Text("\(calories) kcal")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text("·")
                    .foregroundColor(.gray)
                Text(duration)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Button(action: onStart) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.caption2)
                    Text("Start")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.green)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.5), lineWidth: 1)
                )
            }
        }
        .padding(12)
        .frame(width: 180, alignment: .leading)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
    }
}
