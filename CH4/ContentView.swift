//
//  ContentView.swift
//  tesWatch
//
//  Created by Yimei Winata on 23/06/26.
//

import SwiftUI
import ActivityKit
import WatchConnectivity

struct ContentView: View {
    
    init(){
        _ = ConnectivityManager.shared
    }
    
    var body: some View {
        VStack{
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(context.date, format: Date.FormatStyle(date: .omitted, time: .standard))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .padding()
            }
            
            Button("Start") {
                Task {
                    print("Uda kepencet")
                    WCSession.default.transferUserInfo([
                        "type": "start",
                        "seconds": "10",
                        "title": "Ready!"
                    ])
                }
            }
            
            Button("1x Loop Haptics"){
                Task {
                    print("Uda kepencet Haptics 1")
                    WCSession.default.transferUserInfo([
                        "type": "haptics1",
                        "loops": 1
                    ])
                }
            }
            
            Button("2x Loop Haptics"){
                Task {
                    print("Uda kepencet Haptics 2")
                    WCSession.default.transferUserInfo([
                        "type": "haptics2",
                        "loops": 2
                    ])
                }
            }
        }
    }
}

class ConnectivityManager: NSObject, WCSessionDelegate {
    
    static let shared = ConnectivityManager()
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activated")
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}


#Preview {
    ContentView()
}
