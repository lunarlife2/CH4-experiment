//
//  PulsingFlame.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 09/07/26.
//

import SwiftUI
import Combine

struct AnimatedFlameView: View {
    let frames: [String]
    @State private var currentFrame = 0

    let timer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()

    var body: some View {
        Image(frames[currentFrame])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onReceive(timer) { _ in
                currentFrame = (currentFrame + 1) % frames.count
            }
    }
}
