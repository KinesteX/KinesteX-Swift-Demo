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
    let calories: Double?
    let total_minutes: Int?
    let dif_level: String?
    let translation: ClientTranslation?
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
