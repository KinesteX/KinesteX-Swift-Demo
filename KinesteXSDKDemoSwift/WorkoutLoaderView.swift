//
//  WorkoutLoaderView.swift
//  KinesteXSDKDemoSwift
//
//  Created by T3 Chat on 7/24/25.
//

import SwiftUI
import KinesteXAIKit

/// This view is responsible for fetching the workout data from the API.
/// It shows a loading indicator and then passes the fetched data to the WorkoutPlayerView.
struct WorkoutLoaderView: View {
    /// The specific ID of the workout you want to fetch.
    private let workoutId = "UzqxgEwM44bcYJHvS2JZ"
    
    private let kinestex = KinesteXAIKit(
        apiKey: "YOUR_API_KEY",
        companyName: "YOUR_COMPANY_NAME",
        userId: "YOUR_USER_ID"
    )

    // State to hold the fetched data, loading status, or any errors.
    @State private var fetchedWorkout: WorkoutModel?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                ProgressView("Loading Workout...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
            } else if let workout = fetchedWorkout {
                // Once the workout is fetched, present the player view with the data.
                WorkoutPlayerView(workout: workout)
            } else if let error = errorMessage {
                Text("Failed to load workout: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            // When the view appears, start the task to fetch the workout.
            Task {
                await fetchWorkout()
            }
        }
    }

    /// Fetches a single workout by its ID from the KinesteX API.
    private func fetchWorkout() async {
        let result = await kinestex.fetchContent(
            contentType: .workout,
            id: workoutId
        )

        DispatchQueue.main.async {
            switch result {
            case .workout(let workout):
                self.fetchedWorkout = workout
            case .error(let message):
                self.errorMessage = message
                print("Error fetching workout: \(message)")
            default:
                self.errorMessage = "Unexpected data format received."
                print("Error: Received an unexpected format instead of a single workout.")
            }
            self.isLoading = false
        }
    }
}
