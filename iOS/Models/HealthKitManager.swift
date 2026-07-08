//
//  HealthKitManager.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 01/07/26.
//

import Foundation
import HealthKit
import Observation

@Observable
class HealthKitManager{
    
    let healthStore = HKHealthStore()
    
    var calories: Double = 0
    var authStatus: String = "Not requested"
    var avgHeartRate: Double = 0
    var avgPace: Double = 0
    var avgPaceFormatted: String = "00:00"
    var totalDistanceKm: Double = 0
    var totalTimeFormatted: String = "0h 0m"
    
    var age: Int?
    var heightCM: Double?
    var weightKG: Double?
    var maxHeartRateBPM: Int?
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set = [
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.heartRate),
            HKQuantityType(.distanceWalkingRunning),
            HKObjectType.workoutType(),
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKQuantityType(.height),
            HKQuantityType(.bodyMass)
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                self.fetchTodayCalories()
                self.fetchAverageHeartRate()
                self.fetchTodayWorkoutStats()
                self.fetchProfileData()
            }
        }
    }
    
    
    func fetchTodayCalories() {
        let type = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async {
                self.calories = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            }
        }
        healthStore.execute(query)
    }
    
    
    func fetchAverageHeartRate() {
        let type = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            DispatchQueue.main.async {
                let unit = HKUnit.count().unitDivided(by: .minute())
                self.avgHeartRate = result?.averageQuantity()?.doubleValue(for: unit) ?? 0
            }
        }
        healthStore.execute(query)
    }
    
    
    func fetchTodayWorkoutStats() {
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date()
        )
        
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] _, samples, error in
            guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else {
                DispatchQueue.main.async {
                    self?.avgPace = 0
                    self?.avgPaceFormatted = "00:00"
                    self?.totalDistanceKm = 0
                    self?.totalTimeFormatted = "0h 0m"
                }
                return
            }
            
            var totalDurationMinutes: Double = 0
            var totalDistanceKm: Double = 0
            
            for workout in workouts {
                totalDurationMinutes += workout.duration / 60
                
                if let distance = workout.totalDistance {
                    totalDistanceKm += distance.doubleValue(for: .meterUnit(with: .kilo))
                }
            }
            
            DispatchQueue.main.async {
                self?.calculatePace(durationMinutes: totalDurationMinutes, distanceKm: totalDistanceKm)
            }
        }
        
        healthStore.execute(query)
    }
    
    
    func calculatePace(durationMinutes: Double, distanceKm: Double) {
        guard distanceKm > 0 else {
            self.avgPace = 0
            self.avgPaceFormatted = "00:00"
            return
        }
        
        let pace = durationMinutes / distanceKm
        self.avgPace = pace
        self.avgPaceFormatted = formatPace(pace)
    }
    
    func formatDuration(minutes totalMinutes: Double) -> String {
        let hours = Int(totalMinutes) / 60
        let minutes = Int(totalMinutes) % 60
        return "\(hours)h \(minutes)m"
    }
    
    
    // Convert pace from 5.5 minute/km to "05:30"
    func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    func fetchProfileData() {
         fetchAge()
         fetchHeight()
         fetchWeight()
         fetchMaxHeartRate()
     }
     
     func fetchAge() {
         do {
             let birthdayComponents = try healthStore.dateOfBirthComponents()
             guard let birthDate = Calendar.current.date(from: birthdayComponents) else { return }
             let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
             DispatchQueue.main.async {
                 self.age = ageComponents.year
             }
         } catch {
             print("Gagal ambil tanggal lahir: \(error.localizedDescription)")
         }
     }
     
     func fetchHeight() {
         let type = HKQuantityType(.height)
         let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
         let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
             guard let sample = samples?.first as? HKQuantitySample else { return }
             DispatchQueue.main.async {
                 self.heightCM = sample.quantity.doubleValue(for: .meterUnit(with: .centi))
             }
         }
         healthStore.execute(query)
     }
     
     func fetchWeight() {
         let type = HKQuantityType(.bodyMass)
         let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
         let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
             guard let sample = samples?.first as? HKQuantitySample else { return }
             DispatchQueue.main.async {
                 self.weightKG = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
             }
         }
         healthStore.execute(query)
     }
     
     func fetchMaxHeartRate() {
         let type = HKQuantityType(.heartRate)
         let predicate = HKQuery.predicateForSamples(
             withStart: Calendar.current.date(byAdding: .day, value: -90, to: Date()),
             end: Date()
         )
         let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteMax) { _, result, _ in
             let unit = HKUnit.count().unitDivided(by: .minute())
             let maxBPM = result?.maximumQuantity()?.doubleValue(for: unit)
             DispatchQueue.main.async {
                 if let maxBPM {
                     self.maxHeartRateBPM = Int(maxBPM)
                 } else if let age = self.age {
                     self.maxHeartRateBPM = 220 - age
                 }
             }
         }
         healthStore.execute(query)
     }
}
