//
//  PlanAPIService.swift
//  KinesteXSDKDemoSwift
//
//  Created on 2/24/26.
//

import Foundation

// MARK: - API Error

enum PlanAPIError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, body: String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .httpError(let code, let body):
            return "HTTP \(code): \(body)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Response Models

struct ClientPlan: Decodable {
    let id: String
    let title: String
    let description: String?
    let img_url: String?
    let level: String?
    let is_active: Bool?
    let body_parts: [String]?
    let category_levels: [CategoryLevel]?
    let currentWorkout: ClientCurrentWorkout?
    let weeks: [ClientWeek]?
}

struct CategoryLevel: Decodable {
    let name: String?
    let score: Int?
}

struct ClientCurrentWorkout: Decodable {
    let id: String?
    let title: String?
    let img_url: String?
    let desc_img_url: String?
    let calories: Double?
    let total_minutes: Int?
    let total_time: Int?
    let dif_level: String?
    let category: String?
    let body_parts: [String]?
    let workout_sequences: [ClientWorkoutSequenceItem]?
    let translation: ClientTranslation?

    enum CodingKeys: String, CodingKey {
        case id, title, img_url, desc_img_url, calories, total_minutes, total_time
        case dif_level, category, body_parts, workout_sequences, translation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Handle id as either Int or String from API
        if let intId = try? container.decode(Int.self, forKey: .id) {
            id = String(intId)
        } else {
            id = try? container.decode(String.self, forKey: .id)
        }
        title = try? container.decodeIfPresent(String.self, forKey: .title)
        img_url = try? container.decodeIfPresent(String.self, forKey: .img_url)
        desc_img_url = try? container.decodeIfPresent(String.self, forKey: .desc_img_url)
        calories = try? container.decodeIfPresent(Double.self, forKey: .calories)
        total_minutes = try? container.decodeIfPresent(Int.self, forKey: .total_minutes)
        total_time = try? container.decodeIfPresent(Int.self, forKey: .total_time)
        dif_level = try? container.decodeIfPresent(String.self, forKey: .dif_level)
        category = try? container.decodeIfPresent(String.self, forKey: .category)
        body_parts = try? container.decodeIfPresent([String].self, forKey: .body_parts)
        workout_sequences = try? container.decodeIfPresent([ClientWorkoutSequenceItem].self, forKey: .workout_sequences)
        translation = try? container.decodeIfPresent(ClientTranslation.self, forKey: .translation)
    }

    var displayTitle: String {
        translation?.title ?? title ?? category ?? "Current Workout"
    }

    /// Processes workout_sequences into exercise items, filtering out rest sequences
    /// and associating rest durations from following rest entries.
    func processedExercises() -> [WorkoutExerciseItem] {
        guard let sequences = workout_sequences else { return [] }
        let sorted = sequences.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        var result: [WorkoutExerciseItem] = []

        for (index, seq) in sorted.enumerated() {
            guard seq.is_rest_sequence != true,
                  let exercise = seq.exercise,
                  let exerciseId = exercise.id else {
                continue
            }
            // Rest duration comes from the following rest sequence
            var restDuration: Int = 0
            if index + 1 < sorted.count, sorted[index + 1].is_rest_sequence == true {
                restDuration = sorted[index + 1].countdown ?? 0
            }
            result.append(WorkoutExerciseItem(
                exerciseId: exerciseId,
                title: exercise.translation?.title ?? "Exercise",
                reps: seq.repeats,
                countdown: seq.countdown,
                restDuration: restDuration
            ))
        }
        return result
    }
}

// MARK: - Workout Sequence Models

struct ClientWorkoutSequenceItem: Decodable {
    let order: Int?
    let countdown: Int?
    let repeats: Int?
    let is_rest_sequence: Bool?
    let exercise_id: Int?
    let exercise: ClientSequenceExercise?
}

struct ClientSequenceExercise: Decodable {
    let id: String?
    let ai_model: ClientAIModel?
    let thumbnail_url: String?
    let video_url: String?
    let male_thumbnail_url: String?
    let male_video_url: String?
    let body_parts: [String]?
    let difficulty_level: String?
    let translation: ClientExerciseTranslation?
}

struct ClientAIModel: Decodable {
    let id: String?
}

struct ClientExerciseTranslation: Decodable {
    let title: String?
    let description: String?
    let rest_speech: String?
    let rest_speech_text: String?
    let common_mistakes: String?
    let tips: [String]?
    let exercise_steps: [String]?
}

/// Processed exercise item used for display and custom workout launch
struct WorkoutExerciseItem: Identifiable {
    let id = UUID()
    let exerciseId: String
    let title: String
    let reps: Int?
    let countdown: Int?
    let restDuration: Int?
}

struct ClientWeek: Decodable {
    let id: Int?
    let week_number: Int?
    let title: String?
    let description: String?
    let isActive: Bool?
    let isComplete: Bool?
    let translation: ClientTranslation?
    let days: [ClientDay]?
}

struct ClientDay: Decodable {
    let id: Int?
    let day_number: Int?
    let is_rest: Bool?
    let title: String?
    let isCompleted: Bool?
    let isActive: Bool?
    let translation: ClientTranslation?
    let workout: ClientDayWorkout?

    var completed: Bool {
        isCompleted ?? false
    }
}

struct ClientDayWorkout: Decodable {
    let id: String?
    let img_url: String?
    let title: String?
    let description: String?
    let calories: Double?
    let total_minutes: Int?
}

struct ClientTranslation: Decodable {
    let id: Int?
    let language: String?
    let title: String?
    let description: String?
    let dif_level: String?
}

struct PersonalPlan: Decodable {
    let plan_id: String?
    let current_week: Int?
    let current_day: Int?
    let current_workout: ClientCurrentWorkout?
    let weeks: [ClientWeek]?
    let translation: ClientTranslation?
    let re_test_assessment: Bool?
}

// MARK: - API Service

class PlanAPIService {
    private let apiKey: String
    private let userId: String
    private let lang: String
    private let baseURL = "https://data.kinestex.com"

    init(apiKey: String, userId: String, lang: String = "en") {
        self.apiKey = apiKey
        self.userId = userId
        self.lang = lang
    }

    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        request.setValue(lang, forHTTPHeaderField: "Accept-Language")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    func fetchPlan(id: String) async -> Result<ClientPlan, PlanAPIError> {
        guard let url = URL(string: "\(baseURL)/api/plans/client/\(id)") else {
            return .failure(.invalidURL)
        }

        let request = makeRequest(url: url)
        print("[PlanAPI] GET \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.networkError(URLError(.badServerResponse)))
            }

            let bodyString = String(data: data, encoding: .utf8) ?? ""
            print("[PlanAPI] Response \(httpResponse.statusCode): \(bodyString.prefix(500))")

            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(.httpError(statusCode: httpResponse.statusCode, body: bodyString))
            }

            let decoder = JSONDecoder()
            let plan = try decoder.decode(ClientPlan.self, from: data)
            return .success(plan)
        } catch let error as DecodingError {
            print("[PlanAPI] Decoding error: \(error)")
            return .failure(.decodingError(error))
        } catch {
            return .failure(.networkError(error))
        }
    }

    func fetchPersonalPlan() async -> Result<PersonalPlan, PlanAPIError> {
        guard let url = URL(string: "\(baseURL)/api/plans/personal_plans/client/me") else {
            return .failure(.invalidURL)
        }

        let request = makeRequest(url: url)
        print("[PlanAPI] GET \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.networkError(URLError(.badServerResponse)))
            }

            let bodyString = String(data: data, encoding: .utf8) ?? ""
            print("[PlanAPI] Response \(httpResponse.statusCode): \(bodyString.prefix(500))")

            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(.httpError(statusCode: httpResponse.statusCode, body: bodyString))
            }

            let decoder = JSONDecoder()
            let plan = try decoder.decode(PersonalPlan.self, from: data)
            return .success(plan)
        } catch let error as DecodingError {
            print("[PlanAPI] Decoding error: \(error)")
            return .failure(.decodingError(error))
        } catch {
            return .failure(.networkError(error))
        }
    }
}
