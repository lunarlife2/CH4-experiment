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
                        Task {
                            await sessionManager.endSession()
                            await MainActor.run {
                                navigateToEnd = true
                            }
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
                    EndRunningView(finalTimeInZone: sessionManager.displayedTimeInZone,
                                   selectedZone: sessionManager.selectedZones.zone)
                        .environment(sessionManager)
                }
                
                VStack {
                    Button {
                        print("Pause button tapped")
                        let willPause = sessionManager.healthMonitor.sessionState != .paused
                        sessionManager.healthMonitor.togglePause()
                        
                        if willPause {
                            sessionManager.pauseTimer()
                        } else {
                            sessionManager.resumeTimer()
                        }
                        
                        if !ConnectivityManager.shared.isApplyingRemoteState {
                            ConnectivityManager.shared.sendWorkoutState(willPause ? "paused" : "running")
                        }
                    }
                    label: {
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
            .onChange(of: ConnectivityManager.shared.remoteWorkoutState) { _, newState in
                applyRemoteState(newState)
            }
        }
    }
    private func applyRemoteState(_ state: String) {
        ConnectivityManager.shared.isApplyingRemoteState = true
        
        switch state {
        case "paused":
            if sessionManager.healthMonitor.sessionState != .paused {
                sessionManager.healthMonitor.togglePause()
                sessionManager.pauseTimer()
            }
            ConnectivityManager.shared.isApplyingRemoteState = false
            
        case "running":
            if sessionManager.healthMonitor.sessionState == .paused {
                sessionManager.healthMonitor.togglePause()
                sessionManager.resumeTimer()
            }
            ConnectivityManager.shared.isApplyingRemoteState = false
            
        case "ended":
            Task {
                await sessionManager.endSession()
                await MainActor.run {
                    
                    ConnectivityManager.shared.isApplyingRemoteState = false
                    navigateToEnd = true
                }
            }
            
        default:
            ConnectivityManager.shared.isApplyingRemoteState = false
            break
        }
    }
}


#Preview {
    EndPauseView()
        .environment(RunningSessionManager())
}
