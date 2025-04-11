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
        if HKHealthStore.isHealthDataAvailable() {
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
        } else {
            
            //TODO da gestire il caso in cui healthkit non è disonibile
            return false
        }

        return true
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
            results.append(HealthDataModel(iconName: "figure.walk", title: "Passi", date: formattedDate(stepsResult.startDate), value: "\(value)"))
        }

        if let heartRateResult = try await heartRate {
            let value = Int(heartRateResult.quantity.doubleValue(for: HKUnit(from: "count/min")))
            results.append(HealthDataModel(iconName: "heart.fill", title: "Frequenza Cardiaca", date: formattedDate(heartRateResult.startDate), value: "\(value) bpm"))
        }

        if let sleepResult = try await sleep {
            let duration = Int(sleepResult.endDate.timeIntervalSince(sleepResult.startDate) / 60)
            let hours = duration / 60
            let minutes = duration % 60
            results.append(HealthDataModel(iconName: "bed.double.fill", title: "Sonno", date: formattedDate(sleepResult.startDate), value: "\(hours)h \(minutes)m"))
        }
        
        if let hrvResult = try await hrv {
            let hrvValue = hrvResult.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)) // HRV è in secondi → converti in millisecondi
            let intValue = Int(hrvValue)
            results.append(HealthDataModel(iconName: "waveform.path.ecg", title: "HRV", date: formattedDate(hrvResult.startDate), value: "\(intValue) ms"))
        }
        
        if let distanceResult = try await distance {
            let value = distanceResult.quantity.doubleValue(for: HKUnit.meter())
            results.append(HealthDataModel(iconName: "figure.walk", title: "Distanza", date: formattedDate(distanceResult.startDate), value: String(format: "%.2f m", value)))
        }
        
        if let energyResult = try await energy {
            let value = Int(energyResult.quantity.doubleValue(for: HKUnit.kilocalorie()))
            results.append(HealthDataModel(iconName: "flame", title: "Energia Attiva", date: formattedDate(energyResult.startDate), value: "\(value) kcal"))
        }
        
        if let mindfulSessionResult = try await mindfulSession {
            let duration = Int(mindfulSessionResult.endDate.timeIntervalSince(mindfulSessionResult.startDate) / 60)
            results.append(HealthDataModel(iconName: "mindfulness", title: "Sessione Mindful", date: formattedDate(mindfulSessionResult.startDate), value: "\(duration) min"))
        }

        return results
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
}
