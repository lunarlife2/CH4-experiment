//
//  ZoneAConsistency.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//

import SwiftUI

struct ZoneConsistencyView: View {
    var ratios: [Double]

    private let zoneColors: [Color] = [.blue, .green, .yellow, .orange, .red]
    private let maxBarHeight: CGFloat = 44

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(0..<5, id: \.self) { index in
                let ratio = index < ratios.count ? ratios[index] : 0
                RoundedRectangle(cornerRadius: 3)
                    .fill(zoneColors[index])
                    .frame(width: 10, height: max(6, CGFloat(ratio) * maxBarHeight))
            }
        }
        .frame(height: maxBarHeight, alignment: .bottom)
        .animation(.easeInOut(duration: 0.3), value: ratios)
    }
}

#Preview {
    ZoneConsistencyView(ratios: [0.35, 0.30, 0.20, 0.10, 0.05])
        .padding()
        .background(Color.black)
}
