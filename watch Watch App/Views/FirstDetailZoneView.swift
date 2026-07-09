//
//  FirstDetailZoneView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI

struct FirstDetailZoneView: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    @State private var healthMonitor = HealthMonitor()
    
    let zones: [(color: Color, label: String)] = [
        (.blue, "Zone 1"),
        (.green, "Zone 2"),
        (.yellow, "Zone 3"),
        (.brown, "Zone 4"),
        (.red, "Zone 5")
    ]
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack(spacing: 1) {
                ForEach(zones.indices, id: \.self) { index in
                    let zone = zones[index]
                    let isActive = (index + 1) == sessionManager.currentZones
                    
                    HStack (alignment: .firstTextBaseline, spacing: 2) {
                        if isActive {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                            Text(zone.label)
                                .bold()
                                .font(.system(size: 12))
                        }
                    }
                    .padding(isActive ? 12 : 8)
                    .frame(width: isActive ? nil : 25, height: 35)
                    .background(RoundedRectangle(cornerRadius: 5).fill(isActive ? zone.color : zone.color.opacity(0.4)))
                    .animation(.easeInOut, value: sessionManager.selectedZones.zone)
                }
            }
            .padding(.bottom, 10)
            
            HStack (alignment: .firstTextBaseline, spacing: 1) {
                Text("\(Int(sessionManager.healthMonitor.heartRate))")
                    .font(.system(size: 15, weight: .semibold))
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.red)
                    .font(.system(size: 15))

            }
            .padding(.bottom, 10)
            
            VStack (alignment: .leading) {
                Text("Total Time")
                    .font(.system(size: 12, weight: .light))
                Text(sessionManager.formatDuration(sessionManager.totalElapsedTime))
                    .font(.system(size: 15, weight: .semibold))
            }
            .padding(.bottom, 10)
            
            VStack (alignment: .leading) {
                Text("Distance")
                    .font(.system(size: 12, weight: .light))
                HStack (spacing: 0) {
                    Text("\(Int(sessionManager.healthMonitor.distanceFormatted))")
                        .font(.system(size: 15, weight: .semibold))
                    Text("KM")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.top, 5)
                }
                
            }
            .padding(.bottom, 10)
            
        }
        .padding()
        
    }
}

#Preview {
    FirstDetailZoneView()
        .environment(RunningSessionManager())
}
