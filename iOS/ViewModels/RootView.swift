//
//  RootView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI

struct ActiveRunConfig: Identifiable {
    let id = UUID()
    let runType: RunType
    let zone: Int
}

struct RootView: View {
    
    @State private var selectedTab: Int = 0
    @EnvironmentObject var settings: UserSettings
    @State private var healthManager = HealthKitManager()
    @State private var profileViewModel: ProfileViewModel
    @State private var runSession = RunSessionManager.shared
    @State private var activeRunConfig: ActiveRunConfig?
    
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
            TabView(selection: $selectedTab) {
                HomeView(
                    healthManager: healthManager,
                    viewModel: profileViewModel
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                RunView(onStartRun: { runType, zone in
                    runSession.configure(age: healthManager.age, weightKG: healthManager.weightKG)
                    activeRunConfig = ActiveRunConfig(runType: runType, zone: zone)
                })
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("Run")
                }
                .tag(1)
                
                ProfileView(
                    viewModel: profileViewModel,
//                    showBackButton: false
                )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
            }
            .tint(Color.secondaryNormal)
            .fullScreenCover(item: $activeRunConfig) { config in
                ActiveRunView(runType: config.runType, zone: config.zone) {
                    activeRunConfig = nil
                    selectedTab = 0
                }
            }
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
