//
//  PrimaryHeartPulse.swift
//  HeartPulse
//
//  Created by Magesh Sridhar on 9/5/24.
//

import SwiftUI
import Combine
import WatchKit

struct PrimaryHeartPulse: View {
    @State private var wiggleAnimate = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let deviceWidth: CGFloat = WKInterfaceDevice.current().screenBounds.width
    let deviceHeight: CGFloat = WKInterfaceDevice.current().screenBounds.height
    @State private var redHeartWidth: Double = 90
    @State private var redHeartAnimatingHeight: Double = 0
    @State private var redHeartHeight: Double = 90
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ZStack {
                    Group {
                        HeartPulses(redHeartWidth: deviceWidth/2, blackHeartWidth: deviceWidth/2.2, expandSizeTo: deviceWidth)
                        ExpandingHeartView(animatingHeight: $redHeartAnimatingHeight, width: $redHeartWidth, height: $redHeartHeight, color: .red)
                            .scaleEffect(wiggleAnimate ? 1.03 : 1)
                        SideGlowHeart(wiggleAnimate: $wiggleAnimate, width: deviceWidth/1.8, height: deviceWidth/2)
                        InnerShadowHeart(wiggleAnimate: $wiggleAnimate, width: deviceWidth/2.5, height: deviceWidth/2.1, color: .black)
                    }
                }
                .frame(width: deviceWidth, height: deviceHeight)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            withAnimation(.spring(duration: 0.2, bounce: 0.8)) {
                redHeartAnimatingHeight = 35
                redHeartHeight = deviceWidth/2
                redHeartWidth = deviceWidth/2
                wiggleAnimate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(duration: 0.4, bounce: 0.8)) {
                    wiggleAnimate = false
                    redHeartAnimatingHeight = 0
                    redHeartHeight = (deviceWidth/2) - 3
                    redHeartWidth = (deviceWidth/2) - 3
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
