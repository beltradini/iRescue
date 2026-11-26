//
//  HealthMonitorManager.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/25/26.
//

import HealthKit
import Combine

final class HealthMonitorManager {
    
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    @Published private(set) var latestHeartRate: Double?
    @Published private(set) var latestHRV: Double?
    
    @discardableResult
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        guard
            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
            let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        else { return false }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [heartRateType, hrvType])
            return true
        } catch {
            return false
        }
    }
    
    func startHeartRateUpdates() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        stopHeartRateUpdates()
        
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(
            type: type,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.handleHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.handleHeartRateSamples(samples)
        }
        
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    func stopHeartRateUpdates() {
        if let heartRateQuery {
            healthStore.stop(heartRateQuery)
        }
        heartRateQuery = nil
    }
    
    nonisolated private func handleHeartRateSamples(_ samples: [HKSample]?) {
        guard let quantitySample = samples?.last as? HKQuantitySample else { return }
        
        let bpm = quantitySample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        
        DispatchQueue.main.async { [weak self] in
            self?.latestHeartRate = bpm
        }
    }
}
