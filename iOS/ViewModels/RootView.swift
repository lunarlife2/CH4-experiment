//
//  RootView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//



import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            RunView()
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Run")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .tint(Color(hex: "C35A1D")) //
    }
}

#Preview {
    RootView()
}
