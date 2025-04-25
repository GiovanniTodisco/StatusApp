//
//  UserProfile.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//


import Foundation
import UIKit

struct UserProfile: Codable {
    let firstName: String
    let lastName: String
    let birthDate: Date
    var height: String
    var weight: String

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

/// Identificativo univoco dell’utente generato localmente.
/// Usato per associare in modo anonimo i dati inviati al server.
extension UIDevice {
    static var appUserID: String {
        if let existing = UserDefaults.standard.string(forKey: Constants.USER_UUID) {
            return existing
        } else {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: Constants.USER_UUID)
            return newID
        }
    }
}
