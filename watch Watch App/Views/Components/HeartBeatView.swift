//
//  HeartBeatView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI
import HealthKit

struct HeartBeatView: View {
    let running: RunningType
    
    var body: some View {
        NavigationStack {
            VStack {
                PrimaryHeartPulse(running: running)
                            
                HStack (spacing: 50){
                    Text("Zone 3")
                        .fontWeight(.semibold)
                    Text("0:46:29")
                        .fontWeight(.semibold)
                }
                .padding(.top, 20)
                
                Text("SLOW DOWN")
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.red)
//                    .padding(.bottom, 20)
                    .padding(.top, 10)
            }
        }
    }
}

#Preview {
    HeartBeatView(running: RunningType(name: "Outdoor Run", icon: "figure.run", activity: .running, location: .outdoor))
}
