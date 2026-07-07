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
                    
                    HStack {
                        if isActive {
                            Image(systemName: "heart.fill")
                            Text(zone.label)
                                .bold()
                                .font(.footnote)
                        }
                    }
                    .padding(isActive ? 12 : 8)
                    .frame(width: isActive ? nil : 25, height: 35)
                    .background(RoundedRectangle(cornerRadius: 5).fill(zone.color))
                    .animation(.easeInOut, value: currentZone)
                }
            }
            
            HStack {
                Text("107")
                    .bold()
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.red)
            }
                        
            .padding()
            
            VStack (alignment: .leading) {
                Text("Total Time")
                Text("0:46:29")
                    .bold()
            }
            .padding()
            
            VStack (alignment: .leading) {
                Text("Distance")
                HStack (spacing: 0) {
                    Text("2")
                        .bold()
                    Text("KM")
                        .font(.system(size: 10))
                        .padding(.top, 5)
                        .bold()
                }
                
            }
            .padding()
            
        }
        
    }
}

#Preview {
    FirstDetailZoneView(currentZone: 1)
}
