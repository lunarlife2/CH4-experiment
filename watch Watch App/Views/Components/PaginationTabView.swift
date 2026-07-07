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
    let running: RunningType
    @State private var mainSelection = 1
    @State private var innerSelection = 0
    
    var body: some View {
        TabView(selection: $mainSelection) {
            Tab(value: 0) {
                EndPauseView(running: running)
            }
            
            Tab(value: 1) {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 0) {
                            HeartBeatView()
                                .frame(width: geo.size.width, height: geo.size.height)
                            
                            FirstDetailZoneView(currentZone: 3)
                                .frame(width: geo.size.width, height: geo.size.height)
                            
                            SecondDetailZoneView(currentZone: 3)
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
    PaginationTabView(running: RunningType(name: "Outdoor Run", icon: "figure.run", activity: .running, location: .outdoor))
}
