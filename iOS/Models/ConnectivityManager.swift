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
    var heartRate: Double = 0
    
    var isPaired: Bool = false
    var isWatchAppInstalled: Bool = false
    var isReachable: Bool = false
    
    var isWatchConnected: Bool {
        isPaired && isWatchAppInstalled
    }
    
    
    override init() {
        super.init()
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("Connecting To WatchOS Success")
        print("Activated:", activationState == .activated)
        print("Paired:", session.isPaired)
        print("Installed:", session.isWatchAppInstalled)
        print("Reachable:", session.isReachable)
        print("Error:", error as Any)
        
        
        DispatchQueue.main.async {
            self.isPaired = session.isPaired
            self.isWatchAppInstalled = session.isWatchAppInstalled
            self.isReachable = session.isReachable
        }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let heartRate = message["heartRate"] as? Double {
                self.heartRate = heartRate
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif // os(iOS)
    
}
