//
//  HealthDataSyncService.swift
//  StatusApp
//
//  Created by Area mobile on 25/04/25.
//


import Foundation

final class HealthDataSyncService {
    static let shared = HealthDataSyncService()

    private init() {}

    func upload(metrics: [HealthMetricData], range: TimeRange) {
        Task.detached(priority: .background) {
            let now = Date()

            let uploadInterval: TimeInterval
            switch range {
            case .day:
                uploadInterval = TimeInterval(Constants.TIME_RANGE_ONE_MINUTE) // 1 minuto
            case .week:
                uploadInterval = TimeInterval(Constants.TIME_RANGE_ONE_DAY) // 1 giorno
            case .month:
                uploadInterval = TimeInterval(Constants.TIME_RANGE_ONE_WEEK) // 1 settimana
            }

            let filtered = metrics.filter { metric in
                let key = "uploadTimestamp_\(metric.metric.rawValue)_\(range.rawValue)"
                if let lastUpload = UserDefaults.standard.object(forKey: key) as? Date,
                   now.timeIntervalSince(lastUpload) < uploadInterval {
                    print("Upload recente per \(key), skip.")
                    return false
                }
                UserDefaults.standard.set(now, forKey: key)
                return true
            }

            guard !filtered.isEmpty else { return }

            do {
                try await HealthDataUploader().upload(filtered)
                print("Upload eseguito per: \(filtered.map { $0.metric.rawValue })")
            } catch {
                print("Errore upload: \(error.localizedDescription)")
            }
        }
    }

    func uploadAlways(metrics: [HealthMetricData]) {
        Task.detached(priority: .background) {
            guard !metrics.isEmpty else { return }

            do {
                try await HealthDataUploader().upload(metrics)
                print("Upload realtime eseguito per: \(metrics.map { $0.metric.rawValue })")
            } catch {
                print("Errore upload realtime: \(error.localizedDescription)")
            }
        }
    }
}
