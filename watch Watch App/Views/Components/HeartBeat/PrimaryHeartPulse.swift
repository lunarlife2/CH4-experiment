//
//  PrimaryHeartPulse.swift
//  HeartPulse
//
//  Created by Magesh Sridhar on 9/5/24.
//

import SwiftUI
import Combine
import WatchKit
import HealthKit
import WorkoutKit

struct PrimaryHeartPulse: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    
    @State private var wiggleAnimate = false
    @State private var animationTask: Task<Void, Never>?
    
    let deviceWidth: CGFloat = WKInterfaceDevice.current().screenBounds.width
    let deviceHeight: CGFloat = WKInterfaceDevice.current().screenBounds.height
    let baseSize: Double = 70
    @State private var redHeartWidth: Double = 70
    @State private var redHeartAnimatingHeight: Double = 0
    @State private var redHeartHeight: Double = 70
    
    let zoneState: ZoneState
    
    private var heartColor: Color {
        switch zoneState {
        case .belowZone: return .yellow
        case .inZone: return .green
        case .aboveZone: return .red
        }
    }
    var body: some View {
        VStack {
            ZStack {
                
                HeartPulses(
                    redHeartWidth: baseSize,
                    blackHeartWidth: baseSize - 5,
                    expandSizeTo: baseSize * 3,
                    healthMonitor: sessionManager.healthMonitor,
                    zoneState: sessionManager.currentZoneState
                )
                
                ExpandingHeartView(
                    animatingHeight: $redHeartAnimatingHeight,
                    width: $redHeartWidth,
                    height: $redHeartHeight,
                    color: heartColor
                )
                .scaleEffect(wiggleAnimate ? 1.03 : 1)
                
                SideGlowHeart(
                    wiggleAnimate: $wiggleAnimate,
                    width: baseSize,
                    height: baseSize
                )
                
                InnerShadowHeart(
                    wiggleAnimate: $wiggleAnimate,
                    width: baseSize - 5,
                    height: baseSize - 5,
                    color: .black
                )
                
                VStack {
                    Text("\(Int(sessionManager.healthMonitor.heartRate))")
                        .font(.system(size: 20))
                        .bold()
                    
                    Text("BPM")
                        .font(.system(size: 9))
                        .bold()
                }
                .onAppear{
                    animateHeartBeat()
                }
                .onChange(of: sessionManager.healthMonitor.heartRate) { _, _ in
                    animateHeartBeat()
                    sessionManager.evaluateZone()
                }
                .onDisappear {
                    animationTask?.cancel()
                }
            }
            .frame(width: deviceWidth, height: deviceHeight)
            
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
        .padding()
    }
    
    
    private func animateHeartBeat() {
        animationTask?.cancel()
        
        animationTask = Task {
            while !Task.isCancelled {
                
                await MainActor.run {
                    withAnimation(.spring(duration: 0.2, bounce: 0.8)) {
                        redHeartAnimatingHeight = 25
                        redHeartHeight = baseSize
                        redHeartWidth = baseSize
                        wiggleAnimate = true
                    }
                }
                
                try? await Task.sleep(for: .milliseconds(150))
                
                await MainActor.run {
                    withAnimation(.spring(duration: 0.4, bounce: 0.8)) {
                        wiggleAnimate = false
                        redHeartAnimatingHeight = 0
                        redHeartHeight = baseSize - 5
                        redHeartWidth = baseSize - 5
                    }
                }
                
                let bpm = max(40, min(sessionManager.healthMonitor.heartRate, 180))
                let interval = 60.0 / bpm
                
                let remain = max(interval - 0.15, 0.05)
                
                try? await Task.sleep(for: .seconds(remain))
            }
        }
    }
}

#Preview {
    PrimaryHeartPulse(zoneState: .belowZone)
        .environment(RunningSessionManager())
}
