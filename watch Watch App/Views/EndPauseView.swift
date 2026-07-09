//
//  EndPauseView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI
import HealthKit

struct EndPauseView: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    @State private var navigateToEnd = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    
                    Button {
                        sessionManager.finalizeZoneTime()
                        sessionManager.stopTimer()
                        ConnectivityManager.shared.sendWorkoutState("ended")
                        Task {
                            await sessionManager.healthMonitor.stopWorkout()
                            navigateToEnd = true
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(Color.red)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    Text("End")
                        .padding(.bottom, 10)
                }
                .navigationDestination(isPresented: $navigateToEnd){
                    EndRunningView()
                        .environment(sessionManager)
                }
                
                VStack {
                    Button {
                        print("Pause button tapped")
                        sessionManager.healthMonitor.togglePause()
                        if sessionManager.healthMonitor.sessionState == .paused {
                            sessionManager.pauseTimer()
                            ConnectivityManager.shared.sendWorkoutState("paused")
                        } else {
                            sessionManager.resumeTimer()
                            ConnectivityManager.shared.sendWorkoutState("resume")
                        }
                    } label: {
                        Image(systemName: sessionManager.healthMonitor.sessionState == .paused ? "arrow.trianglehead.clockwise" : "pause")
                    }
                    .tint(Color.yellow)
                    .padding(.horizontal, 40)
                    
                    Text(sessionManager.healthMonitor.sessionState == .paused ? "Resume" : "Pause")
                        .padding(.bottom, 10)
                }
                
            }
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Text(sessionManager.runningType.name)
                        .padding(.top, 10)
                        .font(.system(size: 14))
                    
                }
            }
        }
    }
}


#Preview {
    EndPauseView()
        .environment(RunningSessionManager())
}
