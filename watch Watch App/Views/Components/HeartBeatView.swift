//
//  HeartBeatView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI

struct HeartBeatView: View {
    var body: some View {
        NavigationStack {
            VStack {
                PrimaryHeartPulse()
                            
                HStack (spacing: 50){
                    Text("Zone 3")
                    Text("0:46:29")
                }
                .padding()
                
                Text("SLOW DOWN")
                    .bold()
                    .foregroundStyle(Color.red)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    HeartBeatView()
}
