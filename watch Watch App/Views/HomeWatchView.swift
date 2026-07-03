//
//  HomeWatchView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 02/07/26.
//

import SwiftUI
import HealthKit

struct HomeWatchView: View {
    
    @State private var connectivity = ConnectivityManager.shared
    @State private var healthMonitor = HealthMonitor()
    
    var body: some View {
        VStack {
            Text("Seconds: " + connectivity.receivedUserInfo)
                .bold()
            
            Text("\(Int(healthMonitor.heartRate)) BPM")
            
            Button("Start"){
                Task {
                    await healthMonitor.detectHeartRate(
                        activityType: .running,
                        locationType: .indoor)
                }
            }
        }
        .task{
            await healthMonitor.requestAuthorization()
        }
    }
}

#Preview {
    HomeWatchView()
}
