//
//  HeartRateMonitor.swift
//  CH4
//
//  Created by Yimei Winata on 01/07/26.
//

import HealthKit
import WatchKit
import Combine

class HeartRateMonitor: NSObject, ObservableObject {
    
    private let healthStore = HKHealthStore()
    private let heartRateQuantity = HKUnit(from: "count/min")
    
    @Published var currentBPM: Int = 0
    
    // Sesuaikan range yang kamu mau
    private let minRange: Int = 60
    private let maxRange: Int = 100
    
    func start() {
        authorize()
    }
    
    private func authorize() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let types: Set = [heartRateType]
        
        healthStore.requestAuthorization(toShare: [], read: types) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.enableBackgroundDelivery()
                    self.startObserving()
                }
            } else {
                print("❌ Authorization gagal: \(String(describing: error))")
            }
        }
    }
    
    private func enableBackgroundDelivery() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            print("Background delivery: \(success)")
        }
    }
    
    private func startObserving() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            self?.handleSamples(samples)
        }
        
        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.handleSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    private func handleSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample], let latest = samples.last else { return }
        
        let bpm = Int(latest.quantity.doubleValue(for: heartRateQuantity))
        
        DispatchQueue.main.async {
            self.currentBPM = bpm
            self.checkRange(bpm)
        }
    }
    
    private func checkRange(_ bpm: Int) {
        if bpm >= minRange && bpm <= maxRange {
            print("✅ BPM \(bpm) masuk range, trigger haptic")
            WKInterfaceDevice.current().play(.notification)
            // atau panggil hapticLoop(loops: 2) versi kamu
        }
    }
}
