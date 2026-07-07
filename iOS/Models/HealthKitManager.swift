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
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set = [
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.heartRate),
            HKQuantityType(.distanceWalkingRunning),
            HKObjectType.workoutType()
        ]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                self.fetchTodayCalories()
                self.fetchAverageHeartRate()
                self.fetchTodayWorkoutStats()
                
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
    
    
}
