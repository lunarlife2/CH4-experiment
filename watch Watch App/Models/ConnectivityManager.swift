//
//  ConnectivityManager.swift
//  CH4
//
//  Created by Yimei Winata on 02/07/26.
//

import Foundation
import WatchConnectivity
import WatchKit
import Combine
import Observation
import AVFoundation

@Observable
class ConnectivityManager: NSObject, WCSessionDelegate {
    
    var receivedUserInfo: String = "0"
    var remoteWorkoutState: String = "idle"
    
    static let shared = ConnectivityManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    var remoteHeartRate: Double = 0
    var remoteCalories: Double = 0
    var remoteAvgPace: String = "0'00''"
    var remoteDistance: Double = 0
    var remoteElapsedTime: TimeInterval = 0
    var remoteTimeInZone: TimeInterval = 0
    var remoteZone: Int = 1
    
    
    var zone1Min: Int = UserDefaults.standard.integer(forKey: "zone1Min")
    var zone1Max: Int = UserDefaults.standard.integer(forKey: "zone1Max")
    var zone2Min: Int = UserDefaults.standard.integer(forKey: "zone2Min")
    var zone2Max: Int = UserDefaults.standard.integer(forKey: "zone2Max")
    var zone3Min: Int = UserDefaults.standard.integer(forKey: "zone3Min")
    var zone3Max: Int = UserDefaults.standard.integer(forKey: "zone3Max")
    var zone4Min: Int = UserDefaults.standard.integer(forKey: "zone4Min")
    var zone4Max: Int = UserDefaults.standard.integer(forKey: "zone4Max")
    var zone5Min: Int = UserDefaults.standard.integer(forKey: "zone5Min")
    var zone5Max: Int = UserDefaults.standard.integer(forKey: "zone5Max")
    
    //connect watch and ios
    var isApplyingRemoteState = false
    var onRemoteWorkoutStateChanged: ((String) -> Void)?
    
    override init() {
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendWorkoutState(_ state: String) {
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        
        try? session.updateApplicationContext(["workoutState": state])
        
        if session.isReachable {
            session.sendMessage(
                ["workoutState": state],
                replyHandler: { reply in
                    print("iOS confirmed workoutState received:", reply)
                },
                errorHandler: { error in
                    print("sendWorkoutState gagal, fallback ke context:", error)
                }
            )
        }
    }
    
    func sendLiveMetrics(heartRate: Double, calories: Double, avgPace: String, distance: Double, elapsedTime: TimeInterval, timeInZone: TimeInterval, zoneSelected: Int) {
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else { return }
        
        let metrics: [String: Any] = [
            "heartRate": heartRate,
            "calories": calories,
            "avgPace": avgPace,
            "distance": distance,
            "elapsedTime": elapsedTime,
            "timeInZone": timeInZone,
            "zoneSelected": zoneSelected
        ]
        
        session.sendMessage(metrics, replyHandler: { reply in
            print("iOS confirmed metrics received:", reply)
        }, errorHandler: { error in
            print("sendLiveMetrics gagal:", error)
        })
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let state = message["workoutState"] as? String {
                self.remoteWorkoutState = state
                self.onRemoteWorkoutStateChanged?(state)
            }
        }
    }
    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            let defaults = UserDefaults.standard
            
            for (key, value) in applicationContext {
                if let intValue = value as? Int {
                    defaults.set(intValue, forKey: key)
                }
            }
            
            self.zone1Min = applicationContext["zone1Min"] as? Int ?? self.zone1Min
            self.zone1Max = applicationContext["zone1Max"] as? Int ?? self.zone1Max
            self.zone2Min = applicationContext["zone2Min"] as? Int ?? self.zone2Min
            self.zone2Max = applicationContext["zone2Max"] as? Int ?? self.zone2Max
            self.zone3Min = applicationContext["zone3Min"] as? Int ?? self.zone3Min
            self.zone3Max = applicationContext["zone3Max"] as? Int ?? self.zone3Max
            self.zone4Min = applicationContext["zone4Min"] as? Int ?? self.zone4Min
            self.zone4Max = applicationContext["zone4Max"] as? Int ?? self.zone4Max
            self.zone5Min = applicationContext["zone5Min"] as? Int ?? self.zone5Min
            self.zone5Max = applicationContext["zone5Max"] as? Int ?? self.zone5Max
            
            if let state = applicationContext["workoutState"] as? String {
                self.remoteWorkoutState = state
                self.onRemoteWorkoutStateChanged?(state)
            }
            print("Zones Received: ", applicationContext)
        }
    }
    
    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        
        synthesizer.speak(utterance)
    }
    
    func warmUpSynthesizer() {
        let warmupUtterance = AVSpeechUtterance(string: "null")
        warmupUtterance.volume = 0.0
        synthesizer.speak(warmupUtterance)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("Connecting From iOS Success")
        
        DispatchQueue.main.async {
            let context = session.receivedApplicationContext
            if !context.isEmpty {
                self.session(session, didReceiveApplicationContext: context)
            }
        }
    }
    
    func sendHeartRate(_ bpm: Double) {
        let session = WCSession.default
        guard session.activationState == .activated else {return}
        
        session.sendMessage(
            ["heartRate" : bpm],
            replyHandler: nil,
            errorHandler: { error in
                print(error)
            }
        )
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        WKInterfaceDevice.current().play(.notification)
        
        print("Received:", userInfo)
        
        DispatchQueue.main.async {
            if let dataText = userInfo["seconds"] as? String {
                self.receivedUserInfo = dataText
                self.speak("Aku alarm")
            }
        }
    }
}

extension ConnectivityManager {
    var allZones: [HeartRateZone] {
        [
            HeartRateZone(zone: 1, min: zone1Min, max: zone1Max),
            HeartRateZone(zone: 2, min: zone2Min, max: zone2Max),
            HeartRateZone(zone: 3, min: zone3Min, max: zone3Max),
            HeartRateZone(zone: 4, min: zone4Min, max: zone4Max),
            HeartRateZone(zone: 5, min: zone5Min, max: zone5Max),
        ]
    }
}

