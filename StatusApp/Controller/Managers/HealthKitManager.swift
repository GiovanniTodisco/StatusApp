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
            let allTypes: Set = [
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            ]
            
            try await healthStore.requestAuthorization(toShare: allTypes, read: allTypes)
        } else {
            
            //TODO da gestire il caso in cui healthkit non è disonibile
            return false
        }

        return true
    }
}
