//
//  ActiveRunView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//

import SwiftUI

struct ActiveRunView: View {
    let runType: RunType
    let zone: Int
    var onEnd: () -> Void
    
    @State private var session = RunSessionManager.shared
    @State private var connectivity = ConnectivityManager.shared
    @State private var showSummary = false
    
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(runType == .outdoor ? "Outdoor Run" : "Indoor Run")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 24)
                
                distanceCard
                
                HStack(spacing: 14) {
                    metricCard(title: "Duration", value: session.durationFormatted, unit: nil)
                    metricCard(title: "Calories Burned", value: "\(Int(session.caloriesBurned))", unit: "kcal")
                }
                
                HStack(spacing: 14) {
                    paceCard
                    if runType == .outdoor {
                        liveTrackCard
                    } else {
                        zoneConsistencyCard
                    }
                }
                
                Spacer()
                
                controlButtons
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .fullScreenCover(isPresented: $showSummary) {
            RunSummaryView(
                runType: session.isRemoteRun
                ? (connectivity.remoteRunTypeLocation == "indoor" ? .indoor : .outdoor)
                : session.runType,
                
                distanceKm: session.isRemoteRun
                ? connectivity.remoteDistance
                : session.distanceKm,
                
                duration: session.isRemoteRun
                ? connectivity.remoteElapsedTime
                : session.duration,
                
                averagePace: session.isRemoteRun
                ? connectivity.remoteElapsedTime
                : session.averagePace,
                
                caloriesBurned: session.isRemoteRun
                ? connectivity.remoteCalories
                : session.caloriesBurned,
                zoneSecondsSpent: session.isRemoteRun
                ? [:]
                : session.zoneSecondsSpent,
                
                onDismiss: {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showSummary = false
                    }
                    onEnd()
                }
            )
        }
        .onAppear {
            if !session.isRunning {
                session.startRun(type: runType, zone: zone)
            }
            
        }
    }
    
    
    private var distanceCard: some View {
        HStack(spacing: 0) {
            Image(systemName: runType == .outdoor ? "figure.run" : "figure.run.treadmill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.secondaryNormal)
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(Color(white: 0.14))
            
            VStack(alignment: .center, spacing: 8) {
                Text("DISTANCE")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", session.distanceKm))
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                    Text("km")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color(white: 0.10))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func metricCard(title: String, value: String, unit: String?) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                if let unit {
                    Text(unit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(Color(white: 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var paceCard: some View {
        VStack(spacing: 8) {
            Text("Average Pace")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
            Text("(min/km)")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(session.averagePaceFormatted)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text("min/km")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(white: 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var liveTrackCard: some View {
        VStack(spacing: 8) {
            Text("Live Track")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
            
            TrackMapView(coordinates: session.routeCoordinates)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(white: 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var zoneConsistencyCard: some View {
        VStack(spacing: 8) {
            Text("Zone\nConsistency")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
            
            ZoneConsistencyView(ratios: session.zoneConsistencyRatios)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(white: 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var controlButtons: some View {
        GlassEffectContainer(spacing: 28) {
            HStack(spacing: 28) {
                controlButton(systemName: "xmark", tint: .red.opacity(0.8), size: 84) {
                    session.endRun()
                    
                    if !ConnectivityManager.shared.isApplyingRemoteState {
                        ConnectivityManager.shared.sendWorkoutState("ended")
                    }
                    showSummary = true
                }
                
                controlButton(
                    systemName: session.isPaused ? "play.fill" : "pause.fill",
                    tint: Color.secondaryNormal,
                    size: 84
                ) {
                    session.togglePause()
                    if !ConnectivityManager.shared.isApplyingRemoteState {
                        ConnectivityManager.shared.sendWorkoutState(session.isPaused ? "paused" : "resume")
                    }
                }
                
                controlButton(systemName: "arrow.counterclockwise", tint: .green.opacity(0.8), size: 84) {
                    session.resetRun()
                }
            }
        }
        .onChange(of: ConnectivityManager.shared.remoteWorkoutState) { _, newState in
            applyRemoteState(newState)
        }
    }
    
    private func controlButton(systemName: String, tint: Color, size: CGFloat = 68, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.32, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
        }
        .glassEffect(.regular.tint(tint).interactive(), in: Circle())
    }
    
    private func applyRemoteState(_ state: String) {
        ConnectivityManager.shared.isApplyingRemoteState = true
        defer { ConnectivityManager.shared.isApplyingRemoteState = false }
        
        switch state {
        case "paused":
            if session.isRunning && !session.isPaused { session.togglePause() }
        case "resume":
            if session.isRunning && session.isPaused { session.togglePause() }
        case "ended":
            if session.isRunning {
                session.endRun()
                showSummary = true
            }
        default:
            break
        }
    }
}

#Preview("Outdoor") {
    ActiveRunView(runType: .outdoor, zone: 2, onEnd: {})
}

#Preview("Indoor") {
    ActiveRunView(runType: .indoor, zone: 3, onEnd: {})
}
