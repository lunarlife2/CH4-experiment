//
//  HeartBeatView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI
import HealthKit

struct HeartBeatView: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    
    @State private var healthMonitor = HealthMonitor()
    
    var body: some View {
        NavigationStack {
            VStack {
                PrimaryHeartPulse(zoneState: sessionManager.currentZoneState)
                            
                HStack (spacing: 50){
                    Text("Zone \(sessionManager.currentZones)")
                        .fontWeight(.semibold)
                    Text(sessionManager.formatDuration(sessionManager.totalElapsedTime))
                        .fontWeight(.semibold)
                }
                .padding(.top, 20)
                
                
                if sessionManager.currentZoneState == .belowZone {
                    Text("SPEED UP!")
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.yellow)
                        .padding(.top, 10)
                }
                else if sessionManager.currentZoneState == .inZone {
                    Text("IN THE ZONE")
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.green)
                        .padding(.top, 10)
                }
                else {
                    Text("SLOW DOWN")
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.red)
                        .padding(.top, 10)
                }
                
            }
        }
    }
}

#Preview {
    HeartBeatView()
        .environment(RunningSessionManager())
}
