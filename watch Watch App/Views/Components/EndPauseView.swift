//
//  EndPauseView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI
import HealthKit

struct EndPauseView: View {
    let running: RunningType
    @State private var isTapped = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    NavigationLink {
                        EndRunningView()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.white)
                    }
                    .tint(Color.red)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    
                    Text("End")
                        .padding(.bottom, 10)
                }
                
                VStack {
                    Button {
                        print("pause button tapped")
                        isTapped.toggle()
                    } label: {
                        Image(systemName: isTapped ? "arrow.trianglehead.clockwise" : "pause")
                    }
                    .tint(Color.yellow)
                    .padding(.horizontal, 40)
                    
                    Text(isTapped ? "Resume" : "Pause")
                        .padding(.bottom, 10)
                }

            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Text("\(running.name)")
                        
                }
            }
        }
    }
}

#Preview {
    EndPauseView(running: RunningType(name: "Outdoor Run", icon: "figure.run", activity: .running, location: .outdoor))
}
