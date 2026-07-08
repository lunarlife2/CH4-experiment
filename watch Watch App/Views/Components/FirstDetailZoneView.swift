//
//  FirstDetailZoneView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI

struct FirstDetailZoneView: View {
    let currentZone: Int
    
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
                    let isActive = (index + 1) == currentZone
                    
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
                    .background(RoundedRectangle(cornerRadius: 5).fill(zone.color))
                    .animation(.easeInOut, value: currentZone)
                }
            }
            .padding(.bottom, 10)
            
            HStack (alignment: .firstTextBaseline, spacing: 1) {
                Text("107")
                    .font(.system(size: 15, weight: .semibold))
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.red)
                    .font(.system(size: 15))
                
            }
            .padding(.bottom, 10)
            
            VStack (alignment: .leading) {
                Text("Total Time")
                    .font(.system(size: 12, weight: .light))
                Text("0:46:29")
                    .font(.system(size: 15, weight: .semibold))
            }
            .padding(.bottom, 10)
            
            VStack (alignment: .leading) {
                Text("Distance")
                    .font(.system(size: 12, weight: .light))
                HStack (spacing: 0) {
                    Text("2")
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
    FirstDetailZoneView(currentZone: 1)
}
