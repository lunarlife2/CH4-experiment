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
    var weeklyActivity: [DailyActivity] = []
    var weeklySummary = WeeklySummary()
    var sessionLog: [RunSession] = []
    
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
                self.fetchTodayPace()
                self.fetchWeeklyActivity()
                self.fetchWeeklySummary()
                self.fetchSessionLog()
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
    
    
    func fetchTodayPace() {
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
    
    
    // Convert pace from 5.5 minute/km to "05:30"
    func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    func fetchWeeklyActivity() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return }
        
        let type = HKQuantityType(.distanceWalkingRunning)
        
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: startDate),
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { [weak self] _, results, error in
            guard let results = results else { return }
            
            var dailyData: [DailyActivity] = []
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E" // "Sun", "Mon", etc
            
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                let distanceKm = statistics.sumQuantity()?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0
                let dayLabel = dayFormatter.string(from: statistics.startDate)
                let score = distanceKm * 10
                
                dailyData.append(
                    DailyActivity(
                        day: dayLabel,
                        date: statistics.startDate,
                        indoorScore: score * 0.4,   // example split indoor/outdoor
                        outdoorScore: score * 0.6
                    )
                )
            }
            
            DispatchQueue.main.async {
                self?.weeklyActivity = dailyData
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchWeeklySummary() {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return }
        
        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now)
        
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] _, samples, error in
            guard let workouts = samples as? [HKWorkout] else { return }
            
            var totalDistance: Double = 0
            var totalDurationMinutes: Double = 0
            
            for workout in workouts {
                totalDurationMinutes += workout.duration / 60
                if let distance = workout.totalDistance {
                    totalDistance += distance.doubleValue(for: .meterUnit(with: .kilo))
                }
            }
            
            let avgPace = totalDistance > 0 ? totalDurationMinutes / totalDistance : 0
            let hours = Int(totalDurationMinutes) / 60
            let minutes = Int(totalDurationMinutes) % 60
            
            // this week vs past week for "Weekly Trend"
            self?.calculateWeeklyTrend(currentDistance: totalDistance, referenceDate: startOfWeek) { trend in
                DispatchQueue.main.async {
                    self?.weeklySummary = WeeklySummary(
                        totalDistanceKm: totalDistance,
                        avgPaceFormatted: self?.formatPace(avgPace) ?? "00:00",
                        totalHours: hours,
                        totalMinutes: minutes,
                        weeklyTrend: trend
                    )
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    
    func calculateWeeklyTrend(currentDistance: Double, referenceDate: Date, completion: @escaping (String) -> Void) {
        let calendar = Calendar.current
        guard let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: referenceDate),
              let lastWeekEnd = calendar.date(byAdding: .day, value: -1, to: referenceDate) else {
            completion("Stable")
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: lastWeekStart, end: lastWeekEnd)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            let lastWeekDistance = (samples as? [HKWorkout])?.reduce(0.0) { sum, workout in
                sum + (workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0)
            } ?? 0
            
            let trend = currentDistance > lastWeekDistance ? "Increasing" :
                        currentDistance < lastWeekDistance ? "Decreasing" : "Stable"
            completion(trend)
        }
        healthStore.execute(query)
    }

    
    func fetchSessionLog() {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now)
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] _, samples, error in
            guard let workouts = samples as? [HKWorkout] else { return }
            
            let sessions = workouts.compactMap { workout -> RunSession? in
                let distanceKm = workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)) ?? 0
                guard distanceKm > 0 else { return nil }
                
                let durationMinutes = workout.duration / 60
                let pace = durationMinutes / distanceKm
                
                return RunSession(
                    date: workout.startDate,
                    distanceKm: distanceKm,
                    paceFormatted: "\(self?.formatPace(pace) ?? "00:00") /KM"
                )
            }
            
            DispatchQueue.main.async {
                self?.sessionLog = sessions
            }
        }
        
        healthStore.execute(query)
    }
}
