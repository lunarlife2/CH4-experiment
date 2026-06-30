//
//  ContentView.swift
//  tesWatch2 Watch App
//
//  Created by Yimei Winata on 23/06/26.
//

import SwiftUI
import WatchConnectivity
import UserNotifications

struct ContentView: View {
    init(){
        _ = ConnectivityManager.shared
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Ayuk!")
        }
        .padding()
        .task {
            await NotificationManager.shared.requestPermission()
        }
    }
    
    
    
}



#Preview {
    ContentView()
}
