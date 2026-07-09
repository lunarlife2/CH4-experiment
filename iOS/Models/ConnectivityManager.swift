//
//  ConnectivityManager.swift
//  CH4
//
//  Created by Yimei Winata on 02/07/26.
//

import Foundation
import WatchConnectivity
import Combine

@Observable
class ConnectivityManager: NSObject, WCSessionDelegate{
    static let shared = ConnectivityManager()
    
    private var pendingContext: [String: Any]?
    
    var heartRate: Double = 0
    var isPaired: Bool = false
    var isWatchAppInstalled: Bool = false
    var isReachable: Bool = false
    
    var isWatchConnected: Bool {
        isPaired && isWatchAppInstalled
    }
    
    //Data dari watchos
    var remoteWorkoutState: String = "idle"
    var remoteHeartRate: Double = 0
    var remoteCalories: Double = 0
    var remoteAvgPace: String = "0'00''"
    var remoteDistance: Double = 0
    var remoteElapsedTime: TimeInterval = 0
    var remoteTimeInZone: TimeInterval = 0
    var remoteRunTypeLocation: String = "outdoor"
    var remoteZoneSelected: Int = 1
    
    //connect watchos and ios
    var onRemoteWorkoutStateChanged: ((String) -> Void)?
    var isApplyingRemoteState = false
    
    private let pendingStateKey = "pendingWorkoutStateIOS"
    private var pendingWorkoutState: String? {
        get { UserDefaults.standard.string(forKey: pendingStateKey) }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: pendingStateKey)
            } else {
                UserDefaults.standard.removeObject(forKey: pendingStateKey)
            }
        }
    }
    private var retryTimer: Timer?

    func sendWorkoutState(_ state: String) {
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        pendingWorkoutState = state
        try? session.updateApplicationContext(["workoutState": state])
        attemptSend(state: state)
    }

    private func attemptSend(state: String) {
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        session.sendMessage(["workoutState": state], replyHandler: { [weak self] _ in
            if self?.pendingWorkoutState == state {
                self?.pendingWorkoutState = nil
            }
            self?.retryTimer?.invalidate()
            self?.retryTimer = nil
        }, errorHandler: { [weak self] error in
            print("sendWorkoutState (iOS) gagal, akan di-retry:", error)
            self?.scheduleRetry()
        })
    }

    private func scheduleRetry() {
        retryTimer?.invalidate()
        retryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self, let pending = self.pendingWorkoutState else {
                self?.retryTimer?.invalidate()
                self?.retryTimer = nil
                return
            }
            self.attemptSend(state: pending)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("Connecting To WatchOS Success")
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
            self.trySendPendingContext()

            if let pending = self.pendingWorkoutState {
                self.attemptSend(state: pending)
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            if session.isReachable, let pending = self.pendingWorkoutState {
                self.attemptSend(state: pending)
            }
        }
    }
    override init() {
        super.init()
        print("ConnectivityManager init")
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendZonesToWatch(_ settings: UserSettings) {
        
        print("sendZonesToWatch called")
        
        let context: [String: Any] = [
            "zone1Min": settings.zone1Min, "zone1Max": settings.zone1Max,
            "zone2Min": settings.zone2Min, "zone2Max": settings.zone2Max,
            "zone3Min": settings.zone3Min, "zone3Max": settings.zone3Max,
            "zone4Min": settings.zone4Min, "zone4Max": settings.zone4Max,
            "zone5Min": settings.zone5Min, "zone5Max": settings.zone5Max,
        ]
        
        pendingContext = context
        trySendPendingContext()
    }
    
//    func sendWorkoutState(_ state: String) {
//        let session = WCSession.default
//        guard session.activationState == .activated else { return }
//        
//        try? session.updateApplicationContext(["workoutState": state])
//        
//        if session.isReachable {
//            session.sendMessage(
//                ["workoutState": state],
//                replyHandler: nil,
//                errorHandler: { error in
//                    print("sendWorkoutState (iOS) gagal:", error)
//                }
//            )
//        }
//    }
//    
    private func trySendPendingContext() {
        print("trySendPendingContext called")
        
        guard WCSession.default.activationState == .activated,
              let context = pendingContext else {
            print("Belum activated / belum ada pending context, nunggu...")
            return
        }
        
        do {
            try WCSession.default.updateApplicationContext(context)
            print("Zones sent to watch", context)
            pendingContext = nil
        } catch {
            print("Failed sent to watch", error)
        }
    }
    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
//        print("Connecting To WatchOS Success")
//        print("Activated:", activationState == .activated)
//        print("Paired:", session.isPaired)
//        print("Installed:", session.isWatchAppInstalled)
//        print("Reachable:", session.isReachable)
//        print("Error:", error as Any)
//        
//        
//        DispatchQueue.main.async {
//            self.isPaired = session.isPaired
//            self.isWatchAppInstalled = session.isWatchAppInstalled
//            self.isReachable = session.isReachable
//            self.trySendPendingContext()
//        }
//    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("didReceiveMessage fired:", message)
        
        DispatchQueue.main.async {
            if let location = message["runTypeLocation"] as? String {
                self.remoteRunTypeLocation = location
            }
            
            if let zone = message["zoneSelected"] as? Int {
                self.remoteZoneSelected = zone
            }
            
            if let state = message["workoutState"] as? String {
                self.remoteWorkoutState = state
                self.onRemoteWorkoutStateChanged?(state)
            }
            
            if let hr = message["heartRate"] as? Double {
                self.remoteHeartRate = hr
            }
            
            if let cal = message["calories"] as? Double {
                self.remoteCalories = cal
            }
            
            if let pace = message["avgPace"] as? String {
                self.remoteAvgPace = pace
            }
            
            if let dist = message["distance"] as? Double {
                self.remoteDistance = dist
            }
            
            if let elapsed = message["elapsedTime"] as? Double {
                self.remoteElapsedTime = elapsed
            }
            
            if let zoneTime = message["timeInZone"] as? Double {
                self.remoteTimeInZone = zoneTime
            }        }
        
        replyHandler(["status": "received", "keys": Array(message.keys)])
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let state = applicationContext["workoutState"] as? String {
                self.remoteWorkoutState = state
                self.onRemoteWorkoutStateChanged?(state)
            }
        }
    }
    
//    func sessionReachabilityDidChange(_ session: WCSession) {
//        DispatchQueue.main.async {
//            self.isReachable = session.isReachable
//        }
//    }
    
    
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif // os(iOS)
    
}


