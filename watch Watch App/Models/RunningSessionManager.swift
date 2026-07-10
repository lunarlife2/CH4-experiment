//
//  RunningSessionManager.swift
//  CH4
//
//  Created by Yimei Winata on 08/07/26.
//

import Foundation
import HealthKit
import Combine
import WatchKit

@Observable
class RunningSessionManager {
    static let shared = RunningSessionManager()
    
    //Zones
    var selectedZones: SelectedZones = SelectedZones.init(zone: 1)
    var selectedZoneRange: HeartRateZone? {
        ConnectivityManager.shared.allZones.first {
            $0.zone == selectedZones.zone
        }
    }
    var currentZones: Int = 1
    var currentZoneState: ZoneState = .belowZone
    var timeInZone: TimeInterval = 0
    
    //Running Type
    var runningType: RunningType = RunningType.running.first ?? RunningType(
        name: "Outdoor Run", icon: "figure.run", activity: .running, location: .outdoor
    )
    
    var sessionStartTime: Date?
    var totalElapsedTime: TimeInterval = 0
    private var timer: Timer?
    private var zoneEntryTime: Date?
    private var pausedDuration: TimeInterval = 0
    private var pauseStartTime: Date?
    
    var displayedTimeInZone: TimeInterval = 0
    
    //Health
    var healthMonitor = HealthMonitor()
    var avgPace: Double = 0
    
    //connect ios and watchos state
    private var isApplyingRemoteState = false
    var isPaused: Bool = false
    private var isEnding = false
    var sessionDidEnd: Bool = false
    var finalTimeInZone: TimeInterval = 0
    var finalZone: Int = 1
    var onSessionEnded: (() -> Void)?
    private var currentSessionID: UUID?
    
    init() {
        ConnectivityManager.shared.onRemoteWorkoutStateChanged = { [weak self] state in
            self?.applyRemoteState(state)
        }
    }
    
    private func applyRemoteState(_ state: String) {
        print("RunningSessionManager.applyRemoteState called with:", state, "sessionStartTime:", sessionStartTime as Any)
        
        
        guard sessionStartTime != nil else {
            print("Ignoring remote state \(state) — session belum mulai")
            return
        }
        isApplyingRemoteState = true
        switch state {
        case "paused":
            pauseTimer()
        case "running":
            resumeTimer()
        case "ended":
            Task {
                await self.endSession()
                self.isApplyingRemoteState = false
            }
            return
        default:
            break
        }
    }
    
    func resetSessionState() {
        timeInZone = 0
        zoneEntryTime = nil
        totalElapsedTime = 0
        pausedDuration = 0
        pauseStartTime = nil
        currentZoneState = .belowZone
        currentZones = 1
        sessionDidEnd = false
    }
    
    func evaluateZone() {
        guard !isPaused else { return }
        
        let heartRate = Int(healthMonitor.heartRate)
        
        print("Evaluate called")
        print("Heart Rate:", heartRate)
        
        if let matchedZone = ConnectivityManager.shared.allZones.first(where: {heartRate >= $0.min && heartRate <= $0.max}) {
            currentZones = matchedZone.zone
            print("Matched Zone:", matchedZone.zone)
        } else {
            print("No Zone Matched")
        }
        
        let newState: ZoneState
        
        guard let zone = selectedZoneRange else {
            print("Selected zone not found")
            return
        }
        
        if heartRate < zone.min {
            newState = .belowZone
        } else if heartRate <= zone.max {
            newState = .inZone
        } else {
            newState = .aboveZone
        }
        
        print("""
        HR: \(heartRate)
        Selected Zone: \(zone.zone)
        Range: \(zone.min)-\(zone.max)
        """)
        
        guard newState != currentZoneState else {return}
        
        if newState == .inZone {
            zoneEntryTime = Date()
        } else if currentZoneState == .inZone, let entryTime = zoneEntryTime {
            timeInZone += Date().timeIntervalSince(entryTime)
            zoneEntryTime = nil
        }
        
        currentZoneState = newState
        triggerHaptic(for: newState)
    }
    
    private func triggerHaptic(for state: ZoneState) {
        let repeatCount: Int
        switch state {
        case .belowZone:
            repeatCount = 2
        case .inZone:
            repeatCount = 1
        case .aboveZone:
            repeatCount = 3
        }
        
        for i in 0..<repeatCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                WKInterfaceDevice.current().play(.notification)
                print("Haptic Success Called")
            }
            
        }
        
    }
    
    func finalizeZoneTime() {
        if currentZoneState == .inZone, let entryTime = zoneEntryTime {
            timeInZone += Date().timeIntervalSince(entryTime)
            zoneEntryTime = nil
        }
    }
    
    func formatDuration(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    func formatDurationText(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d h %d m", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%d m %d s", minutes, seconds)
        } else {
            return String(format: "%d s", seconds)
        }
    }
    func startSession(activityType: HKWorkoutActivityType, locationType: HKWorkoutSessionLocationType) async {
        resetSessionState()
        currentSessionID = UUID()
        let thisSessionID = currentSessionID
        
        healthMonitor.calories = 0
        healthMonitor.heartRate = 0
        healthMonitor.distance = 0
        healthMonitor.avgPace = 0
        healthMonitor.avgPaceFormatted = "00'00''"
        
        if healthMonitor.session != nil {
            await healthMonitor.stopWorkout()
        }
        await healthMonitor.detectHeartRate(activityType: activityType, locationType: locationType)
        sessionStartTime = Date()
        startTimer()
        ConnectivityManager.shared.sendWorkoutState(
            "started",
            runTypeLocation: runningType.location == .indoor ? "indoor" : "outdoor",
            zone: selectedZones.zone
        )
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, let start = self.sessionStartTime else { return }
            
            self.totalElapsedTime = Date().timeIntervalSince(start) - pausedDuration
            
            let durationMinutes = self.totalElapsedTime / 60
            let distanceKm = self.healthMonitor.distance / 1000
            self.healthMonitor.calculatePace(durationMinutes: durationMinutes, distanceKm: distanceKm)
            
            if currentZoneState == .inZone,
               let entry = zoneEntryTime {
                displayedTimeInZone = timeInZone + Date().timeIntervalSince(entry)
            } else {
                displayedTimeInZone = timeInZone
            }
            
            ConnectivityManager.shared.sendLiveMetrics(
                heartRate: healthMonitor.heartRate,
                calories: healthMonitor.calories,
                avgPace: healthMonitor.avgPaceFormatted,
                distance: healthMonitor.distanceFormatted,
                elapsedTime: totalElapsedTime,
                timeInZone: displayedTimeInZone,
                zoneSelected: selectedZones.zone
            )
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func pauseTimer() {
        stopTimer()
        
        if currentZoneState == .inZone,
           let entry = zoneEntryTime {
            
            timeInZone += Date().timeIntervalSince(entry)
            zoneEntryTime = nil
        }
        
        pauseStartTime = Date()
        isPaused = true
        
        if !isApplyingRemoteState {
            ConnectivityManager.shared.sendWorkoutState("paused")
        }
    }
    
    func resumeTimer() {
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        if currentZoneState == .inZone {
            zoneEntryTime = Date()
        }
        
        isPaused = false
        startTimer()
        
        if !isApplyingRemoteState {
            ConnectivityManager.shared.sendWorkoutState("running")
        }
    }
    
    func endSession() async {
        guard !isEnding else {
            print("endSession() dipanggil lagi, diabaikan")
            return
        }
        isEnding = true
        defer { isEnding = false }
        
        stopTimer()
        finalizeZoneTime()
        
        displayedTimeInZone = timeInZone
        finalTimeInZone = timeInZone
        finalZone = selectedZones.zone
        print("endSession - timeInZone:", timeInZone, "zone:", selectedZones.zone)
        
        ConnectivityManager.shared.sendLiveMetrics(
            heartRate: healthMonitor.heartRate,
            calories: healthMonitor.calories,
            avgPace: healthMonitor.avgPaceFormatted,
            distance: healthMonitor.distanceFormatted,
            elapsedTime: totalElapsedTime,
            timeInZone: displayedTimeInZone,
            zoneSelected: selectedZones.zone
        )
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        await healthMonitor.stopWorkout()
        
        sessionDidEnd = true
        print("sessionDidEnd set to true, displayedTimeInZone:", displayedTimeInZone)
        await MainActor.run {
            onSessionEnded?()
        }
        
        if !isApplyingRemoteState {
            ConnectivityManager.shared.sendWorkoutState("ended")
        }
    }
}

nonisolated enum ZoneState {
    case belowZone, inZone, aboveZone
}

enum WatchRoute: Hashable {
    case zonePicker
    case loading
    case pagination
}
