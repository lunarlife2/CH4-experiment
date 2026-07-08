//
//  HeartPulses.swift
//  HeartPulse
//
//  Created by Magesh Sridhar on 9/28/24.
//

import SwiftUI


struct HeartPulses: View {
    
    var redHeartWidth: Double
    var blackHeartWidth: Double
    var expandSizeTo: Double
    
    @State private var expandingHearts: [ExpandingHeart] = []
    @State private var pulseTask: Task<Void, Never>?
    
    var healthMonitor: HealthMonitor
    
    func addHeart() {
        let expandingHeart = ExpandingHeart()
        expandingHearts.append(expandingHeart)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            expandingHearts.removeAll(where: { $0.id == expandingHeart.id })
        }
    }
    
    func interval(for bpm: Double) -> Double {
        let safeBpm = bpm.isFinite && bpm > 0 ? bpm : 70
        let clamped = min(max(safeBpm, 40), 180)
        return 60.0 / clamped
    }
    
    func startPulsing() {
        pulseTask?.cancel()
        pulseTask = Task {
            while !Task.isCancelled {
                addHeart()
                let delay = interval(for: healthMonitor.heartRate)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30, paused: false)) { timeline in
            Canvas { context, size in
                for heart in expandingHearts {
                    if let resolvedView = context.resolveSymbol(id: heart.id) {
                        let centerX = size.width / 2
                        let centerY = size.height / 2
                        context.draw(resolvedView, at: CGPoint(x: centerX, y: centerY))
                    }
                }
            } symbols: {
                ForEach(expandingHearts) { heart in
                    ExpandingHearts(redHeartWidth: redHeartWidth, blackHeartWidth: blackHeartWidth, expandSizeTo: expandSizeTo)
                        .id(heart.id)
                }
            }
        }
        .onAppear {
            startPulsing()
        }
        .onDisappear {
            pulseTask?.cancel()
        }
    }
}
