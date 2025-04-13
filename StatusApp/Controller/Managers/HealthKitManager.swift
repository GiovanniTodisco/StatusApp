//
//  HealthKitManager.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }

        let allTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]

        try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)

        // Crea mappa tra metrica e tipo
        let metricToType: [HealthMetric: HKObjectType] = [
            .frequenzaCardiaca: HKObjectType.quantityType(forIdentifier: .heartRate)!,
            .hrv: HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            .passi: HKObjectType.quantityType(forIdentifier: .stepCount)!,
            .distanza: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            .energiaAttiva: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            .sonno: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            .mindful: HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]

        let authorizedMetrics = metricToType.compactMap { (metric, type) -> String? in
            let status: HKAuthorizationStatus
            if let quantity = type as? HKQuantityType {
                status = healthStore.authorizationStatus(for: quantity)
            } else if let category = type as? HKCategoryType {
                status = healthStore.authorizationStatus(for: category)
            } else {
                return nil
            }

            return status == .sharingAuthorized ? metric.rawValue : nil
        }

        let currentPrefs = ChartsPreferencesManager.load()
        if currentPrefs.selectedMetrics.isEmpty {
            let updatedPrefs = ChartsPreferences(
                selectedMetrics: authorizedMetrics,
                selectedTimeRange: currentPrefs.selectedTimeRange
            )
            ChartsPreferencesManager.save(updatedPrefs)
        }

        return !authorizedMetrics.isEmpty
    }

    func fetchLatestHealthData() async throws -> [HealthDataModel] {
        var results: [HealthDataModel] = []

        async let steps = fetchMostRecentQuantitySample(for: .stepCount)
        async let heartRate = fetchMostRecentQuantitySample(for: .heartRate)
        async let sleep = fetchMostRecentCategorySample(for: .sleepAnalysis)
        async let hrv = fetchMostRecentQuantitySample(for: .heartRateVariabilitySDNN)
        async let distance = fetchMostRecentQuantitySample(for: .distanceWalkingRunning)
        async let energy = fetchMostRecentQuantitySample(for: .activeEnergyBurned)
        async let mindfulSession = fetchMostRecentCategorySample(for: .mindfulSession)

        if let stepsResult = try await steps {
            let value = Int(stepsResult.quantity.doubleValue(for: .count()))
            results.append(HealthDataModel(
                metric: .passi,
                iconName: HealthMetric.passi.iconName,
                title: HealthMetric.passi.rawValue,
                date: formattedDate(stepsResult.startDate),
                value: "\(value)"
            ))
        }

        if let heartRateResult = try await heartRate {
            let value = Int(heartRateResult.quantity.doubleValue(for: HKUnit(from: "count/min")))
            results.append(HealthDataModel(
                metric: .frequenzaCardiaca,
                iconName: HealthMetric.frequenzaCardiaca.iconName,
                title: HealthMetric.frequenzaCardiaca.rawValue,
                date: formattedDate(heartRateResult.startDate),
                value: "\(value) bpm"
            ))
        }

        if let sleepResult = try await sleep {
            let duration = Int(sleepResult.endDate.timeIntervalSince(sleepResult.startDate) / 60)
            let hours = duration / 60
            let minutes = duration % 60
            results.append(HealthDataModel(
                metric: .sonno,
                iconName: HealthMetric.sonno.iconName,
                title: HealthMetric.sonno.rawValue,
                date: formattedDate(sleepResult.startDate),
                value: "\(hours)h \(minutes)m"
            ))
        }
        
        if let hrvResult = try await hrv {
            let hrvValue = hrvResult.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)) // HRV è in secondi → converti in millisecondi
            let intValue = Int(hrvValue)
            results.append(HealthDataModel(metric: .hrv,
                                           iconName: HealthMetric.hrv.iconName,
                                           title: HealthMetric.hrv.rawValue,
                                           date: formattedDate(hrvResult.startDate),
                                           value: "\(intValue) ms"))
        }
        
        if let distanceResult = try await distance {
            let value = distanceResult.quantity.doubleValue(for: HKUnit.meter())
            results.append(HealthDataModel(metric: .distanza,
                                           iconName: HealthMetric.distanza.iconName,
                                           title: HealthMetric.distanza.rawValue,
                                           date: formattedDate(distanceResult.startDate),
                                           value: String(format: "%.2f m", value)))
        }
        
        if let energyResult = try await energy {
            let value = Int(energyResult.quantity.doubleValue(for: HKUnit.kilocalorie()))
            results.append(HealthDataModel(metric: .energiaAttiva,
                                            iconName: HealthMetric.energiaAttiva.iconName,
                                           title: HealthMetric.energiaAttiva.rawValue,
                                           date: formattedDate(energyResult.startDate),
                                           value: "\(value) kcal"))
        }
        
        if let mindfulSessionResult = try await mindfulSession {
            let duration = Int(mindfulSessionResult.endDate.timeIntervalSince(mindfulSessionResult.startDate) / 60)
            results.append(HealthDataModel(metric: .mindful,
                                        	iconName: HealthMetric.mindful.iconName,
                                           title: HealthMetric.mindful.rawValue,
                                           date: formattedDate(mindfulSessionResult.startDate),
                                           value: "\(duration) min"))
        }

        return results
    }

    func fetchHealthData(for preferences: ChartsPreferences) async throws -> [HealthMetricData] {
        var results: [String: [(value: String, dateString: String)]] = [:]

        let calendar = Calendar.current
        let now = Date()
        let startDate: Date = {
            switch preferences.selectedTimeRange {
            case .day:
                return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)) ?? now
            case .week:
                return calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) ?? now
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: calendar.startOfDay(for: now)) ?? now
            }
        }()

        let types: [(type: HKQuantityTypeIdentifier, unit: HKUnit, metric: HealthMetric)] = [
            (.stepCount, .count(), .passi),
            (.heartRate, HKUnit(from: "count/min"), .frequenzaCardiaca),
            (.heartRateVariabilitySDNN, HKUnit.secondUnit(with: .milli), .hrv),
            (.distanceWalkingRunning, .meter(), .distanza),
            (.activeEnergyBurned, .kilocalorie(), .energiaAttiva)
        ].filter { preferences.selectedMetrics.contains($0.metric.rawValue) }

        for (identifier, unit, metric) in types {
            guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { continue }

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
            let anchorDate = calendar.startOfDay(for: now)
            let interval = DateComponents(day: 1)

            let options: HKStatisticsOptions = {
                switch identifier {
                case .heartRate, .heartRateVariabilitySDNN:
                    return .discreteAverage
                default:
                    return .cumulativeSum
                }
            }()

            let statsQuery = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: options,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            try await withCheckedThrowingContinuation { (continuation : CheckedContinuation<Void, Error>) in
                statsQuery.initialResultsHandler = { _, collection, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    var values: [(value: String, dateString: String)] = []
                    collection?.enumerateStatistics(from: startDate, to: now) { stats, _ in
                        let dateStr = self.formattedShortDate(stats.startDate)
                        let value = (options == .discreteAverage) ?
                            stats.averageQuantity()?.doubleValue(for: unit) :
                            stats.sumQuantity()?.doubleValue(for: unit)

                        if let val = value {
                            let formatted = identifier == .distanceWalkingRunning
                                ? String(format: "%.2f", val)
                                : "\(Int(val))"
                            values.append((formatted, dateStr))
                        } else {
                            values.append(("0", dateStr))
                        }
                    }

                    results[metric.rawValue] = values
                    continuation.resume()
                }
                self.healthStore.execute(statsQuery)
            }
        }

        if preferences.selectedMetrics.contains(HealthMetric.sonno.rawValue) {
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let sleepQuery = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                guard error == nil, let categorySamples = samples as? [HKCategorySample] else { return }

                var sleepByDay: [String: Double] = [:]
                for sample in categorySamples where sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue {
                    let dateStr = self.formattedShortDate(sample.startDate)
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    sleepByDay[dateStr, default: 0] += duration
                }

                let sorted = sleepByDay.map { (key, value) in
                    let totalMinutes = Int(value / 60)
                    return ("\(totalMinutes)", key)
                }.sorted { $0.1 < $1.1 }

                results[HealthMetric.sonno.rawValue] = sorted
            }

            self.healthStore.execute(sleepQuery)
        }

        if preferences.selectedMetrics.contains(HealthMetric.mindful.rawValue) {
            let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let mindfulQuery = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                guard error == nil, let categorySamples = samples as? [HKCategorySample] else { return }

                var mindfulByDay: [String: Double] = [:]
                for sample in categorySamples {
                    let dateStr = self.formattedShortDate(sample.startDate)
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    mindfulByDay[dateStr, default: 0] += duration
                }

                let sorted = mindfulByDay.map { (key, value) in
                    let totalMinutes = Int(value / 60)
                    return ("\(totalMinutes)", key)
                }.sorted { $0.1 < $1.1 }

                results[HealthMetric.mindful.rawValue] = sorted
            }

            self.healthStore.execute(mindfulQuery)
        }

        let filteredResults = results.filter { HealthMetric(rawValue: $0.key) != nil }

        return filteredResults.map { (key, values) in
            let metric = HealthMetric(rawValue: key)!
            let mapped = values.map { (entry: (value: String, dateString: String)) in
                MetricValue(date: entry.dateString, value: entry.value)
            }
            return HealthMetricData(metric: metric, values: mapped)
        }
    }
    
    private func fetchMostRecentQuantitySample(for identifier: HKQuantityTypeIdentifier) async throws -> HKQuantitySample? {
        let sampleType = HKSampleType.quantityType(forIdentifier: identifier)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: results?.first as? HKQuantitySample)
                }
            }
            healthStore.execute(query)
        }
    }

    private func fetchMostRecentCategorySample(for identifier: HKCategoryTypeIdentifier) async throws -> HKCategorySample? {
        let sampleType = HKSampleType.categoryType(forIdentifier: identifier)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: results?.first as? HKCategorySample)
                }
            }
            healthStore.execute(query)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}
