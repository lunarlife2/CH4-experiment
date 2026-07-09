//
//  HeartMonitor.swift
//  watch Watch App
//
//  Created by Yimei Winata on 02/07/26.
//

import Foundation
import Combine
import HealthKit
import Observation

@Observable
class HealthMonitor: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    //Health Store and Auth
    let healthStore = HKHealthStore()
    var authStatus: String = "Not requested"
    
    //Session
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var sessionState: HKWorkoutSessionState = .notStarted
    private var endWorkoutContinuation: CheckedContinuation<Void, Never>?
    
    //All Type From Health Kit
    var calories: Double = 0
    var heartRate: Double = 0
    var avgPace: Double = 0
    var avgPaceFormatted: String = "00'00''"
    var distance: Double = 0
    var distanceFormatted: Double {
        distance/1000
    }
    
    func requestAuthorization() async {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        
        let writeTypes: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKWorkoutType.workoutType()
        ]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            authStatus = "HealthKit not available on this device"
            return
        }
        
        do {
            try await healthStore.requestAuthorization(
                toShare: writeTypes,
                read: readTypes
                
            )
            
            let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let workout = HKWorkoutType.workoutType()
            print("HeartRate auth:", healthStore.authorizationStatus(for: heartRate).rawValue)
            print("Workout auth:", healthStore.authorizationStatus(for: workout).rawValue)
            
            authStatus = "Authorization granted"
            
        } catch {
            authStatus = "Authorization failed: \(error.localizedDescription)"
        }
        
        print(authStatus)
        
        
    }
    
    func detectHeartRate(
        activityType: HKWorkoutActivityType,
        locationType: HKWorkoutSessionLocationType
    ) async {
        
        do {
            
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = activityType
            configuration.locationType = locationType
            
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            
            builder = session?.associatedWorkoutBuilder()
            
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            session?.delegate = self
            builder?.delegate = self
            
            session?.prepare()
            
            print("Prepare")
            
            try await builder?.beginCollection(at: Date())
            
            print("Begin Collection")
            
            session?.startActivity(with: Date())
            
            print("Start Activity")
            
            
            
        } catch {
            print(error)
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
    
    func calculatePace(durationMinutes: Double, distanceKm: Double) {
        guard distanceKm > 0 else {
            self.avgPace = 0
            self.avgPaceFormatted = "00'00''"
            return
        }
        
        let pace = durationMinutes / distanceKm
        self.avgPace = pace
        self.avgPaceFormatted = formatPace(pace)
    }
    
    func formatPace(_ pace: Double) -> String {
        guard pace > 0, pace.isFinite else { return "00'00''" }
        let totalSeconds = Int((pace * 60).rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d'%02d''", minutes, seconds)    }
    
    
    func stopWorkout() async {
        guard let session = session,
              session.state != .ended,
              session.state != .notStarted else { return }
        
        try? await builder?.addMetadata([
            "AvgPaceFormatted": avgPaceFormatted,
            "AvgPaceValue": avgPace
        ])
        
        await withCheckedContinuation { continuation in
            self.endWorkoutContinuation = continuation
            session.stopActivity(with: Date())
            session.end()
        }
        
        self.session = nil
        self.builder = nil
        self.sessionState = .notStarted
    }
    
    func togglePause(){
        guard let session = session else {return}
        if session.state == .running {
            session.pause()
        } else if session.state == .paused {
            session.resume()
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("State: \(toState)")
        
        switch toState {
        case .paused:
            sessionState = .paused
        case .running:
            sessionState = .running
        case .ended:
            sessionState = .ended
            Task {
                do {
                    try await builder?.endCollection(at: date)
                    let workout = try await builder?.finishWorkout()
                    print("Workout Finished: ", workout as Any)
                } catch {
                    print("Failed to finish workout: ", error)
                }
                endWorkoutContinuation?.resume()
                endWorkoutContinuation = nil
            }
        default:
            break
        }
    }
    
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        print(error)
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // Heart Rate
        guard let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate),
              collectedTypes.contains(heartRate),
              let statistics = workoutBuilder.statistics(for: heartRate),
              let quantity = statistics.mostRecentQuantity()
                
        else {
            return
        }
        
        let bpm = quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        
        DispatchQueue.main.async {
            self.heartRate = bpm
            ConnectivityManager.shared.sendHeartRate(bpm)
        }
        
        //Calories
        if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
           collectedTypes.contains(energyType),
           let statistics = workoutBuilder.statistics(for: energyType),
           let sum = statistics.sumQuantity() {
            
            let kcal = sum.doubleValue(for: .kilocalorie())
            
            DispatchQueue.main.async {
                self.calories = kcal
            }
        }
        
        //Distance
        if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
           collectedTypes.contains(distanceType),
           let statistics = workoutBuilder.statistics(for: distanceType),
           let sum = statistics.sumQuantity() {
            
            let meters = sum.doubleValue(for: .meter())
            
            DispatchQueue.main.async {
                self.distance = meters
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        let events = workoutBuilder.workoutEvents
        
        for event in events {
            print(event.type)
        }
    }
    
    
}
