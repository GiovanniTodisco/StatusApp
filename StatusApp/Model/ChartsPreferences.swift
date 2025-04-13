//
//  ChartsPreferences.swift
//  StatusApp
//
//  Created by Area mobile on 12/04/25.
//


import Foundation

struct ChartsPreferences: Codable {
    var selectedMetrics: [String]
    var selectedTimeRange: TimeRange

    static let `default` = ChartsPreferences(
        selectedMetrics: ["Passi", "Frequenza Cardiaca", "Distanza"],
        selectedTimeRange: .week
    )
}

enum TimeRange: String, Codable {
    case day
    case week
    case month
}

struct ChartsPreferencesManager {
    static func save(_ preferences: ChartsPreferences) {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: Constants.CHARTS_PREFERENCES)
        }
    }

    static func load() -> ChartsPreferences {
        if let data = UserDefaults.standard.data(forKey: Constants.CHARTS_PREFERENCES),
           let prefs = try? JSONDecoder().decode(ChartsPreferences.self, from: data) {
            return prefs
        }
        return ChartsPreferences.default
    }
}
