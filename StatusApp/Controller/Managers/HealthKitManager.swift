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
            print("Health data non disponibile")
            return false
        }

        let allMetrics: [(metric: HealthMetric, type: HKSampleType)] = [
            (.frequenzaCardiaca, HKObjectType.quantityType(forIdentifier: .heartRate)!),
            (.hrv, HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!),
            (.passi, HKObjectType.quantityType(forIdentifier: .stepCount)!),
            (.distanza, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!),
            (.energiaAttiva, HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!),
            (.sonno, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!),
            (.mindful, HKObjectType.categoryType(forIdentifier: .mindfulSession)!)
        ]

        let typesToRead = Set(allMetrics.map { $0.type })
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        print("Richiesta autorizzazioni completata")

        var authorizedMetrics: [String] = []

        for (metric, type) in allMetrics {
            do {
                if let quantityType = type as? HKQuantityType {
                    let sample = try await fetchMostRecentQuantitySample(for: HKQuantityTypeIdentifier(rawValue: quantityType.identifier))
                    if sample != nil {
                        print("Metrica autorizzata (dati disponibili): \(metric.rawValue)")
                        authorizedMetrics.append(metric.rawValue)
                    }
                } else if let categoryType = type as? HKCategoryType {
                    let sample = try await fetchMostRecentCategorySample(for: HKCategoryTypeIdentifier(rawValue: categoryType.identifier))
                    if sample != nil {
                        print("Metrica autorizzata (dati disponibili): \(metric.rawValue)")
                        authorizedMetrics.append(metric.rawValue)
                    }
                }
            } catch {
                print("Errore lettura per \(metric.rawValue): \(error)")
            }
        }

        print("Metriche autorizzate dall'utente (con dati): \(authorizedMetrics)")

        let currentPrefs = ChartsPreferencesManager.load()
        let updatedPrefs = ChartsPreferences(
            selectedMetrics: authorizedMetrics,
            selectedTimeRange: currentPrefs.selectedTimeRange
        )
        ChartsPreferencesManager.save(updatedPrefs)
        print("Preferenze aggiornate con metriche: \(updatedPrefs.selectedMetrics)")

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
            let values = try await fetchQuantitySamplesGroupedByDay(for: identifier, unit: unit, startDate: startDate, endDate: now)
            results[metric.rawValue] = values
        }

        if preferences.selectedMetrics.contains(HealthMetric.sonno.rawValue) {
            let sleepData = try await fetchCategorySamplesGroupedByDay(for: .sleepAnalysis, startDate: startDate, endDate: now)
            results[HealthMetric.sonno.rawValue] = sleepData
        }

        if preferences.selectedMetrics.contains(HealthMetric.mindful.rawValue) {
            let mindfulData = try await fetchCategorySamplesGroupedByDay(for: .mindfulSession, startDate: startDate, endDate: now)
            results[HealthMetric.mindful.rawValue] = mindfulData
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
    
    /// Recupera l'ultimo campione disponibile per una metrica di tipo `HKQuantityType`
    /// - Parameter identifier: identificatore della metrica (es. .heartRate, .stepCount)
    /// - Returns: il campione più recente (`HKQuantitySample`) o `nil` se non disponibile
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

    /// Recupera l'ultimo campione disponibile per una metrica di tipo `HKCategoryType`
    /// - Parameter identifier: identificatore della metrica (es. .sleepAnalysis, .mindfulSession)
    /// - Returns: il campione più recente (`HKCategorySample`) o `nil` se non disponibile
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
    
    /// Recupera e aggrega i dati giornalieri per una metrica `HKQuantityType`
    /// - Parameters:
    ///   - identifier: identificatore della metrica (es. .stepCount)
    ///   - unit: unità di misura da utilizzare per la conversione
    ///   - startDate: inizio del periodo
    ///   - endDate: fine del periodo
    /// - Returns: array di tuple (valore, data stringa)
    private func fetchQuantitySamplesGroupedByDay(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, startDate: Date, endDate: Date) async throws -> [(value: String, dateString: String)] {
        return try await withCheckedThrowingContinuation { continuation in
            guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
                continuation.resume(returning: [])
                return
            }

            let calendar = Calendar.current
            let anchorDate = calendar.startOfDay(for: Date())
            let interval = DateComponents(day: 1)

            let options: HKStatisticsOptions = {
                switch identifier {
                case .heartRate, .heartRateVariabilitySDNN:
                    return .discreteAverage
                default:
                    return .cumulativeSum
                }
            }()

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: options,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, collection, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                var values: [(value: String, dateString: String)] = []
                collection?.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
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

                continuation.resume(returning: values)
            }

            self.healthStore.execute(query)
        }
    }

    /// Recupera e aggrega i dati giornalieri per una metrica `HKCategoryType`
    /// - Parameters:
    ///   - identifier: identificatore della metrica (es. .sleepAnalysis)
    ///   - startDate: data di inizio del range
    ///   - endDate: data di fine del range
    /// - Returns: array di tuple (valore in minuti, data stringa)
    private func fetchCategorySamplesGroupedByDay(for identifier: HKCategoryTypeIdentifier, startDate: Date, endDate: Date) async throws -> [(value: String, dateString: String)] {
        return try await withCheckedThrowingContinuation { continuation in
            let categoryType = HKObjectType.categoryType(forIdentifier: identifier)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let query = HKSampleQuery(sampleType: categoryType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                guard error == nil, let categorySamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: [])
                    return
                }

                var byDay: [String: Double] = [:]
                for sample in categorySamples {
                    let dateStr = self.formattedShortDate(sample.startDate)
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    byDay[dateStr, default: 0] += duration
                }

                let sorted: [(value: String, dateString: String)] = byDay.map { (key, value) in
                    switch identifier {
                    case .sleepAnalysis:
                        let totalMinutes = Int(value / 60)
                        let hours = totalMinutes / 60
                        let minutes = totalMinutes % 60
                        let formatted = String(format: "%d.%02d", hours, minutes)
                        return (formatted, key)
                    case .mindfulSession:
                        let totalMinutes = "\(Int(value / 60))"
                        return (totalMinutes, key)
                    default:
                        return ("0", key)
                    }
                }.sorted { $0.1 < $1.1 }

                continuation.resume(returning: sorted)
            }

            self.healthStore.execute(query)
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
