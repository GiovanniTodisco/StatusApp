//
//  HealthDataUploader.swift
//  StatusApp
//
//  Created by Area mobile on 25/04/25.
//


import Foundation
import UIKit

struct UploadableMetricData: Codable {
    let metric: String
    let values: [MetricValue]
}

struct UploadablePayload: Codable {
    let userId: String
    let metrics: [UploadableMetricData]
}

final class HealthDataUploader {

    private let endpoint = URL(string: "https://statusapp.free.beeceptor.com")!

    func upload(_ data: [HealthMetricData]) async throws {
        let uploadableData = data.map { metricData in
            UploadableMetricData(
                metric: metricData.metric.rawValue,
                values: metricData.values
            )
            
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let payload = await UploadablePayload(
            userId: UIDevice.appUserID,
            metrics: uploadableData
        )
        let jsonData = try encoder.encode(payload)

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON generato:\n\(jsonString)")
        }

        _ = try await NetworkManager.shared.postJSON(to: endpoint, body: payload)
    }
}
