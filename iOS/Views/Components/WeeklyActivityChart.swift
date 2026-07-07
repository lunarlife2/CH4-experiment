//
//  WeeklyActivityChart.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 06/07/26.
//

import SwiftUI
import Charts

struct WeeklyActivityChart: View {
    let data: [DailyActivity]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Weekly Activity")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Chart {
                ForEach(data) { item in
                    AreaMark(x: .value("Day", item.day), y: .value("Indoor", item.indoorScore))
                        .foregroundStyle(.blue.opacity(0.6))
                    AreaMark(x: .value("Day", item.day), y: .value("Outdoor", item.outdoorScore))
                        .foregroundStyle(.orange.opacity(0.6))
                }
            }
            .frame(height: 200)
        }
    }
}
