//
//  HomeWatchView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 02/07/26.
//

import SwiftUI

struct HomeWatchView: View {
    
    @StateObject private var connectivity = ConnectivityManager.shared
    
    var body: some View {
        VStack {
            Text("Seconds: " + connectivity.receivedUserInfo)
                .bold()
        }
    }
}

#Preview {
    HomeWatchView()
}
