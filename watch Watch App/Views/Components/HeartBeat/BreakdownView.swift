//
//  BreakdownView.swift
//  HeartPulse
//
//  Created by Magesh Sridhar on 9/28/24.
//

import SwiftUI
import HealthKit
import WorkoutKit

struct BreakdownView : View {
    @Binding var wiggleAnimate: Bool
    @Binding var redHeartAnimatingHeight: Double
    @Binding var redHeartWidth: Double
    @Binding var redHeartHeight: Double
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            
            ExpandingHeartView(animatingHeight: $redHeartAnimatingHeight, width: $redHeartWidth, height: $redHeartHeight, color: .red)
            .scaleEffect(wiggleAnimate ? 1.03 : 1)
                .padding()
                .frame(width: 100, height: 100)
            
            
            SideGlowHeart(wiggleAnimate: $wiggleAnimate, width: 200, height: 200)
                .scaleEffect(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 100, height: 100)
            InnerShadowHeart(wiggleAnimate: $wiggleAnimate, width: 120, height: 200, color: .white)
                .scaleEffect(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 100, height: 100)
            HeartPulses(redHeartWidth: 50, blackHeartWidth: 50, expandSizeTo: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 100, height: 100)
        }
    }
}
