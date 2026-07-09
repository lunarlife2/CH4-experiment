//
//  HeartPulses.swift
//  HeartPulse
//
//  Created by Magesh Sridhar on 9/28/24.
//

import SwiftUI

struct HeartPulses: View {
    
    let redHeartWidth: Double
    let blackHeartWidth: Double
    let expandSizeTo: Double
    
    let healthMonitor: HealthMonitor
    
    @State private var expandingHearts: [ExpandingHeart] = []
    @State private var pulseTask: Task<Void, Never>?
    
    let zoneState: ZoneState
    private var heartColor: Color {
        switch zoneState {
        case .belowZone: return .yellow
        case .inZone: return .green
        case .aboveZone: return .red
        }
    }
    
    private func interval() -> Double {
        
        let bpm = max(40, min(healthMonitor.heartRate, 180))
        
        return 60 / bpm
    }
    
    private func addHeart() {
        
        let heart = ExpandingHeart()
        
        expandingHearts.append(heart)
        
        Task {
            
            try? await Task.sleep(for: .seconds(1.6))
            
            await MainActor.run {
                
                expandingHearts.removeAll {
                    $0.id == heart.id
                }
                
            }
        }
    }
    
    private func startLoop() {
        
        pulseTask?.cancel()
        
        pulseTask = Task {
            
            while !Task.isCancelled {
                
                await MainActor.run {
                    
                    addHeart()
                    
                }
                
                try? await Task.sleep(
                    for: .seconds(interval())
                )
                
            }
            
        }
        
    }
    
    var body: some View {
        ZStack {
            
            ForEach(expandingHearts) { heart in
                
                ExpandingHearts(
                    redHeartWidth: redHeartWidth,
                    blackHeartWidth: blackHeartWidth,
                    expandSizeTo: expandSizeTo,
                    zoneState: zoneState
                )
                .id(heart.id)
                
            }
            
        }
        .onAppear {
            startLoop()
        }
        .onDisappear {
            pulseTask?.cancel()
        }
        .onChange(of: healthMonitor.heartRate) { _, _ in
            startLoop()
        }
    }
}
