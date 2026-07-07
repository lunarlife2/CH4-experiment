//
//  SecondDetailZoneView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI

struct SecondDetailZoneView: View {
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
            
            VStack (alignment: .leading) {
                Text("Time in Target Zone")
                    .font(.system(size: 13))
                Text("0:31:09")
                    .bold()
            }
            .padding()
            
            VStack (alignment: .leading) {
                Text("Calorie")
                    .font(.system(size: 13))
                HStack (spacing: 0) {
                    Text("200")
                        .bold()
                    Text("KCal")
                        .font(.system(size: 10))
                        .padding(.top, 5)
                        .bold()
                }
            }
            .padding()
            
            VStack (alignment: .leading) {
                Text("Average Pace")
                    .font(.system(size: 13))
                Text("21'18''")
                    .bold()
                
            }
            .padding()
            
        }
    }
}

#Preview {
    SecondDetailZoneView(currentZone: 1)
}
