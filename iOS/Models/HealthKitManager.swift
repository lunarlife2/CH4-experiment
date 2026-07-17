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
    
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    var calories: Double = 0
    var authStatus: String = "Not requested"
    var avgHeartRate: Double = 0
    var avgPace: Double = 0
    var avgPaceFormatted: String = "00:00"
    var totalDistanceKm: Double = 0
    var totalTimeFormatted: String = "0h 0m"
    var caloriesBurned: Double = 0
    
    var age: Int?
    var heightCM: Double?
    var weightKG: Double?
    var maxHeartRateBPM: Int?
	var isAuthorized: Bool = false
    
    var todayZoneSeconds: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0] //sum for each zone
    
    static let zoneSecondsMetadataKey = "com.ranup.zoneSecondsSpent" //key metadata to HWorkout
    
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
        
        let typesToShare: Set<HKSampleType> = [
             HKObjectType.workoutType(),
             HKQuantityType(.activeEnergyBurned),
             HKQuantityType(.distanceWalkingRunning)
         ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                self.fetchTodayCalories()
                self.fetchAverageHeartRate()
                self.fetchTodayWorkoutStats()
                self.fetchTodayZoneSeconds()
                self.fetchProfileData()
				Task { @MainActor in
					self.isAuthorized = true
				}
            }
        }
    }
    
    
    func saveRun(
        type: RunType,
        distanceKm: Double,
        duration: TimeInterval,
        calories: Double,
        zoneSecondsSpent: [Int: Int] = [:],
        completion: @escaping (Bool) -> Void
    ) {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = type == .indoor ? .indoor : .outdoor

        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: configuration,
            device: .local()
        )

        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: distanceKm * 1000)
            let distanceSample = HKQuantitySample(
                type: HKQuantityType(.distanceWalkingRunning),
                quantity: distanceQuantity,
                start: startDate,
                end: endDate
            )

            let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
            let energySample = HKQuantitySample(
                type: HKQuantityType(.activeEnergyBurned),
                quantity: energyQuantity,
                start: startDate,
                end: endDate
            )

            builder.add([distanceSample, energySample]) { success, error in
                guard success else {
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                //saving the key metada
                var metadata: [String: Any] = [:]
                if let data = try? JSONEncoder().encode(zoneSecondsSpent),
                   let jsonString = String(data: data, encoding: .utf8) {
                    metadata[HealthKitManager.zoneSecondsMetadataKey] = jsonString
                }

                builder.addMetadata(metadata) { success, error in
                    guard success else {
                        DispatchQueue.main.async { completion(false) }
                        return
                    }

                    builder.endCollection(withEnd: endDate) { success, error in
                        guard success else {
                            DispatchQueue.main.async { completion(false) }
                            return
                        }

                        builder.finishWorkout { workout, error in
                            DispatchQueue.main.async {
                                completion(workout != nil)
                                self.fetchTodayZoneSeconds()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func fetchTodayCalories() {
        let startDate = Calendar.current.startOfDay(for: Date())

        let type = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date()
        )

        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in

            let value =
                result?.sumQuantity()?
                .doubleValue(for: .kilocalorie()) ?? 0

            DispatchQueue.main.async {
                self.caloriesBurned = value
            }
        }

        healthStore.execute(query)
    }
    
    
    func fetchCalories(from startDate: Date, completion: @escaping (Double) -> Void) {
        let type = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: Date()
        )

        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in

            let value =
                result?.sumQuantity()?
                .doubleValue(for: .kilocalorie()) ?? 0

            DispatchQueue.main.async {
                completion(value)
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
    
    
    func fetchTodayZoneSeconds() {
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
            guard let workouts = samples as? [HKWorkout] else {
                DispatchQueue.main.async {
                    self?.todayZoneSeconds = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
                }
                return
            }

            var totals: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]

            for workout in workouts {
                guard
                    let jsonString = workout.metadata?[HealthKitManager.zoneSecondsMetadataKey] as? String,
                    let data = jsonString.data(using: .utf8),
                    let perWorkoutZones = try? JSONDecoder().decode([Int: Int].self, from: data)
                else { continue }

                for (zone, seconds) in perWorkoutZones {
                    totals[zone, default: 0] += seconds
                }
            }

            DispatchQueue.main.async {
                self?.todayZoneSeconds = totals
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
