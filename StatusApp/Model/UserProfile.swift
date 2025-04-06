//
//  UserProfile.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//


import Foundation

struct UserProfile: Codable {
    let firstName: String
    let lastName: String
    let birthDate: Date

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Constants.USER_PROFILE_KEY)
            print("User profile saved successfully")
        }
    }

    static func load() -> UserProfile? {
        if let data = UserDefaults.standard.data(forKey: Constants.USER_PROFILE_KEY),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return nil
    }
}
