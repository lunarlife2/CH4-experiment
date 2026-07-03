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
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let heartRate = message["heartRate"] as? Double {
                self.heartRate = heartRate
            }
        }
    }
    
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif // os(iOS)
    
}
