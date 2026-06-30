import Foundation
import HealthKit
import Observation

@Observable
@MainActor
class HealthKitManager {

    let healthStore = HKHealthStore()

    var stepCount: Int = 0
    var activeEnergyBurned: Double = 0
    var authStatus: String = "Not requested"

    func requestAuthorization() async {

        let readTypes: Set<HKSampleType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned)
        ]

        let writeTypes: Set<HKSampleType> = [
            HKQuantityType(.activeEnergyBurned)
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

            authStatus = "Authorization granted"

        } catch {
            authStatus = "Authorization failed: \(error.localizedDescription)"
        }
    }



    func fetchTodayStepCount() async {

        let stepType = HKQuantityType(.stepCount)

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(
                type: stepType,
                predicate: predicate
            ),
            options: .cumulativeSum
        )

        do {

            let result = try await descriptor.result(for: healthStore)

            if let sum = result?.sumQuantity() {
                stepCount = Int(
                    sum.doubleValue(for: .count())
                )
            }

        } catch {
            print("Step count query failed: \(error.localizedDescription)")
        }
    }

    func fetchTodayEnergyBurned() async {

        let energyType = HKQuantityType(.activeEnergyBurned)

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(
                type: energyType,
                predicate: predicate
            ),
            options: .cumulativeSum
        )

        do {

            let result = try await descriptor.result(for: healthStore)

            if let sum = result?.sumQuantity() {

                activeEnergyBurned = sum.doubleValue(
                    for: .kilocalorie()
                )
            }

        } catch {
            print("Energy query failed: \(error.localizedDescription)")
        }
    }



    func addTodayEnergyBurned(calorie: Double) async {

        let energyType = HKQuantityType(.activeEnergyBurned)

        let quantity = HKQuantity(
            unit: .kilocalorie(),
            doubleValue: calorie
        )

        let sample = HKQuantitySample(
            type: energyType,
            quantity: quantity,
            start: Date(),
            end: Date()
        )

        do {

            try await healthStore.save(sample)

            print("Saved \(calorie) kcal")

            await fetchTodayEnergyBurned()

        } catch {

            print("Failed to save: \(error.localizedDescription)")
        }
    }

    // MARK: - Observe Step Changes

    func startObservingCount() {

        let stepType = HKQuantityType(.stepCount)

        let observerQuery = HKObserverQuery(
            sampleType: stepType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in

            if let error {
                print("Observer error: \(error.localizedDescription)")
                completionHandler()
                return
            }

            Task {
                await self?.fetchTodayStepCount()
            }

            completionHandler()
        }

        healthStore.execute(observerQuery)

        healthStore.enableBackgroundDelivery(
            for: stepType,
            frequency: .hourly
        ) { success, error in

            if success {
                print("Background delivery enabled")
            } else {
                print(
                    "Background delivery failed: \(error?.localizedDescription ?? "")"
                )
            }
        }
    }
}
