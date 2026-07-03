//
//  HomeView.swift
//  CH4
//
//  Created by Yimei Winata on 02/07/26.
//

import SwiftUI
import WatchConnectivity


struct HomeView: View {
    @State private var connectivity = ConnectivityManager.shared
    
    var body: some View {
        VStack {
            Text("\(connectivity.heartRate) BPM")
            
            Button("Schedule 10 seconds Alarm") {
                print("Uda kepencet")
                WCSession.default.transferUserInfo([
                    "seconds": "10",
                    "title": "Ready!!!!!"
                ])
            }
        }
    }
}

#Preview {
    HomeView()
}
