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
    @State private var wiggleAnimate = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let deviceWidth: CGFloat = WKInterfaceDevice.current().screenBounds.width
    let deviceHeight: CGFloat = WKInterfaceDevice.current().screenBounds.height
    let baseSize: Double = 70
    @State private var redHeartWidth: Double = 70
    @State private var redHeartAnimatingHeight: Double = 0
    @State private var redHeartHeight: Double = 70
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ZStack {
                    Group {
                        HeartPulses(redHeartWidth: baseSize, blackHeartWidth: baseSize-5, expandSizeTo: baseSize * 3)
                        ExpandingHeartView(animatingHeight: $redHeartAnimatingHeight, width: $redHeartWidth, height: $redHeartHeight, color: .red)
                            .scaleEffect(wiggleAnimate ? 1.03 : 1)
                        SideGlowHeart(wiggleAnimate: $wiggleAnimate, width: baseSize + 5, height: baseSize)
                        InnerShadowHeart(wiggleAnimate: $wiggleAnimate, width: baseSize - 5, height: baseSize - 5, color: .black)
                        
                        VStack {
                            Text("170")
                                .font(.system(size: 20))
                                .bold()
                            Text("BPM")
                                .font(.system(size: 9))
                                .bold()
                        }
                        
                            
                    }
                }
                .frame(width: deviceWidth, height: deviceHeight)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
        .padding()
        .onReceive(timer) { _ in
            withAnimation(.spring(duration: 0.2, bounce: 0.8)) {
                redHeartAnimatingHeight = 25
                redHeartHeight = baseSize
                redHeartWidth = baseSize
                wiggleAnimate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(duration: 0.4, bounce: 0.8)) {
                    wiggleAnimate = false
                    redHeartAnimatingHeight = 0
                    redHeartHeight = baseSize - 3
                    redHeartWidth = baseSize - 3
                }
            }
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }
    }
}

#Preview {
    PrimaryHeartPulse()
}
