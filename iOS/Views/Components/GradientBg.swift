//
//  GradientBg.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI

struct GreadientBg {
    let backgroundGradientStops: [Gradient.Stop] = [
        .init(color: Color(hex: "0B1313").opacity(0.98), location: 0.0),
        .init(color: Color(hex: "143534"), location: 0.39),
        .init(color: Color(hex: "275957"), location: 1.0)
    ]

    var backgroundGradient: LinearGradient {
        LinearGradient(
            stops: backgroundGradientStops,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
