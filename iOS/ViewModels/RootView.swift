//
//  RootView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

//
//  RootView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var settings: UserSettings
    @State private var healthManager = HealthKitManager()
    @State private var profileViewModel: ProfileViewModel
    
    init() {
        let sharedHealthManager = HealthKitManager()
        _healthManager = State(wrappedValue: sharedHealthManager)
        _profileViewModel = State(wrappedValue: ProfileViewModel(
            name: "Xera Kenedy",
            email: "xeraKen.edit@icoud.com",
            healthManager: sharedHealthManager
        ))
    }
    
    var body: some View {
        if !settings.onboarding {
            OnboardingView()
        } else {
            TabView {
                HomeView(
                    healthManager: healthManager,
                    viewModel: profileViewModel
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                
                RunView(onStartRun: { runType, zone in
                    print("Selected: \(runType), zone: \(zone)")
                })
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Run")
                }
                
                // PERUBAHAN: pakai profileViewModel yang sama (bukan bikin baru),
                // dan tambah showBackButton: false karena ini root tab-nya sendiri
                ProfileView(
                    viewModel: profileViewModel,
//                    showBackButton: false
                )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            }
            .tint(Color.secondaryNormal)
        }
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
        .environmentObject(UserSettings())
}
