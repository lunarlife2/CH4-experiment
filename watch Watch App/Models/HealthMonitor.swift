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
import WorkoutKit

@Observable
class HealthMonitor: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    let healthStore = HKHealthStore()
    var heartRate: Double = 0
    var authStatus: String = "Not requested"
    
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    func requestAuthorization() async {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        
        let writeTypes: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
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
    
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("State: \(toState)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        print(error)
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
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
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        let events = workoutBuilder.workoutEvents
        
        for event in events {
            print(event.type)
        }
    }
    
    
}
