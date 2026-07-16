//
//  RunModels.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//


import Foundation
import CoreLocation
import Observation


enum RunType {
    case indoor, outdoor
}

enum RunSetupStep {
    case selectType
    case configureZone
}

@Observable
class RunSessionManager: NSObject, CLLocationManagerDelegate {
    
    private let healthKitManager: HealthKitManager
    private var runStartDate: Date?
    static let shared = RunSessionManager()
    
    
    private(set) var runType: RunType = .outdoor
    private(set) var zone: Int = 2
    
    var isRunning: Bool = false
    var isPaused: Bool = false
    
    var elapsedSeconds: Int = 0
    var distanceKm: Double = 0
    var caloriesBurned: Double = 0
    var currentHeartRate: Double = 0
    
    var routeCoordinates: [CLLocationCoordinate2D] = []
    
    
    var zoneSecondsSpent: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    
    
    private var age: Int = 0
    private var weightKG: Double = 00
    
    
    private var timer: Timer?
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    //connect watchos and ios state
    private var isApplyingRemoteState = false
    var isRemoteRun: Bool = false
    
    init(healthKitManager: HealthKitManager = HealthKitManager()) {
        self.healthKitManager = healthKitManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5
        
        ConnectivityManager.shared.onRemoteWorkoutStateChanged = { [weak self] state in
            self?.applyRemoteState(state)
        }
    }
    
    private func applyRemoteState(_ state: String) {
        isApplyingRemoteState = true
        switch state {
        case "paused":
            if isRunning && !isPaused { togglePause() }
        case "running":
            if isRunning && isPaused { togglePause() }
        case "ended":
            if isRunning { endRun() }
        default:
            break
        }
        isApplyingRemoteState = false
    }
    
    
    func configure(age: Int?, weightKG: Double?) {
        if let age { self.age = age }
        if let weightKG { self.weightKG = weightKG }
    }
    
    
    func startRun(type: RunType, zone: Int) {
        runType = type
        self.zone = zone
        resetMetrics()
        
        isRunning = true
        isPaused = false
        runStartDate = Date()
        
        if type == .outdoor {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        startTimer()
    }
    
    
    func togglePause() {
        guard isRunning else { return }
        isPaused.toggle()
        
        if isPaused {
            timer?.invalidate()
            timer = nil
            locationManager.stopUpdatingLocation()
        } else {
            startTimer()
            if runType == .outdoor {
                locationManager.startUpdatingLocation()
            }
        }
        
        if !isApplyingRemoteState {
            ConnectivityManager.shared.sendWorkoutState(isPaused ? "paused" : "running")
        }
    }
    
    
    func resetRun() {
        resetMetrics()
        runStartDate = nil
        isRemoteRun = false   
    }
    
    
    func endRun() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
        
        if !isApplyingRemoteState {
            ConnectivityManager.shared.sendWorkoutState("ended")
        }
    }
    
    private func resetMetrics() {
        elapsedSeconds = 0
        distanceKm = 0
        caloriesBurned = 0
        routeCoordinates = []
        lastLocation = nil
        zoneSecondsSpent = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    }
    
    
    var duration: TimeInterval {
        TimeInterval(elapsedSeconds)
    }
    
    var averagePace: TimeInterval {
        guard distanceKm > 0.01, elapsedSeconds > 0 else { return 0 }
        return (Double(elapsedSeconds) / 60.0) / distanceKm
    }
    
    
    var durationFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var averagePaceFormatted: String {
        guard distanceKm > 0.01, elapsedSeconds > 0 else { return "0:00" }
        let paceSecondsPerKm = (Double(elapsedSeconds)) / distanceKm
        let minutes = Int(paceSecondsPerKm) / 60
        let seconds = Int(paceSecondsPerKm) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    
    var zoneConsistencyRatios: [Double] {
        let total = zoneSecondsSpent.values.reduce(0, +)
        guard total > 0 else { return [0, 0, 0, 0, 0] }
        return (1...5).map { Double(zoneSecondsSpent[$0] ?? 0) / Double(total) }
    }
    
    
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard isRunning, !isPaused else { return }
        elapsedSeconds += 1
        
        currentHeartRate = ConnectivityManager.shared.heartRate
        
        if elapsedSeconds % 1 == 0, let runStartDate {
            healthKitManager.fetchCalories(from: runStartDate) { [weak self] calories in
                self?.caloriesBurned = calories
            }
        }
        
        updateZoneTime()
    }
    
    
    private func updateZoneTime() {
        let z = zoneForCurrentHeartRate()
        zoneSecondsSpent[z, default: 0] += 1
    }
    
    private func zoneForCurrentHeartRate() -> Int {
        guard currentHeartRate > 0 else { return 1 }
        let zones = HeartRateCalculator.calculateZones(age: age)
        for hrZone in zones {
            if Int(currentHeartRate) >= hrZone.min && Int(currentHeartRate) <= hrZone.max {
                return hrZone.zone
            }
        }
        if Int(currentHeartRate) > (zones.last?.max ?? 0) { return 5 }
        return 1
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard runType == .outdoor, isRunning, !isPaused, let newLocation = locations.last else { return }
        
        if let last = lastLocation {
            let deltaKm = newLocation.distance(from: last) / 1000.0
            // Filter GPS noise: ignore tiny/implausible jumps.
            if deltaKm > 0.0015 {
                distanceKm += deltaKm
                routeCoordinates.append(newLocation.coordinate)
            }
        } else {
            routeCoordinates.append(newLocation.coordinate)
        }
        
        lastLocation = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
    }
}
