//
//  PaginationTabView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI
import HealthKit
import WorkoutKit

struct PaginationTabView: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    @State private var mainSelection = 1
    @State private var innerSelection = 0
    
    var body: some View {
        TabView(selection: $mainSelection) {
            Tab(value: 0) {
                EndPauseView()
                    .environment(sessionManager)
            }
            
            Tab(value: 1) {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 0) {
                            HeartBeatView()
                                .frame(width: geo.size.width, height: geo.size.height)
                            
                            FirstDetailZoneView()
                                .frame(width: geo.size.width, height: geo.size.height)
                            
                            SecondDetailZoneView()
                                .frame(width: geo.size.width, height: geo.size.height)

                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                }
                .ignoresSafeArea()
            }
        }
        .tabViewStyle(.page)
        
    }
}

#Preview {
    PaginationTabView()
        .environment(RunningSessionManager())
}
