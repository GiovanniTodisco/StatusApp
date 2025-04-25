//
//  NetworkManager.swift
//  StatusApp
//
//  Created by Area mobile on 25/04/25.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    func postJSON<T: Encodable>(
        to url: URL,
        body: T,
        headers: [String: String] = [:]
    ) async throws -> HTTPURLResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("", forHTTPHeaderField: "Authorization") //jwt

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "UploadFailed", code: 1, userInfo: nil)
        }

        return httpResponse
    }
}
