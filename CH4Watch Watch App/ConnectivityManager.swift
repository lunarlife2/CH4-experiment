//
//  ConnectivityManager.swift
//  tesWatch
//
//  Created by Yimei Winata on 26/06/26.
//

import WatchConnectivity
import WatchKit
import Combine

final class ConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = ConnectivityManager()
    @Published var receivedUserInfo: String = "Menunggu data..."
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {
        print(userInfo)
        WKInterfaceDevice.current().play(.notification)

        DispatchQueue.main.async {
            if let dataText = userInfo["seconds"] as? String {
                self.receivedUserInfo = dataText
            }
        }
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activated")
    }
    
}
