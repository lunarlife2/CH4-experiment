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
    
    @StateObject private var shared = ConnectivityManager()
    var body: some View {
        VStack {
            Text("Seconds: " + shared.receivedUserInfo)
                .padding()
                .bold()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
