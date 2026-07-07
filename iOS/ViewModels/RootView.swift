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
                .toolbarBackground(.green, for: .tabBar)
        }
        .tint(Color(hex: "C35A1D"))
    }
    
    
}
    

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
 
        let r = Double((rgbValue >> 16) & 0xFF) / 255
        let g = Double((rgbValue >> 8) & 0xFF) / 255
        let b = Double(rgbValue & 0xFF) / 255
 
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    RootView()
}
