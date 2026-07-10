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
    //    @State private var sessionManager = RunningSessionManager()
    @State private var sessionManager = RunningSessionManager.shared
    @State private var path = NavigationPath()
    @State private var showEndRunning = false
    
    var body: some View {
        VStack {
            
            TabPagingView()
                .environment(sessionManager)
            
        }
        .environment(sessionManager)
        .task {
            await sessionManager.healthMonitor.requestAuthorization()
        }
    }
}

#Preview {
    HomeWatchView()
}
