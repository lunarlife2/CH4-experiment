//
//  RunSummary.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI

struct RunSummary: View {
    let summary: WeeklySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RUN SUMMARY")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 10) {
                statColumn(label: "Total Dist.",
                           value: String(format: "%.1f",summary.totalDistanceKm), unit: "KM")
                statColumn(label: "Avg. Pace",
                           value: summary.avgPaceFormatted, unit: "/KM")
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Time")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text("\(summary.totalHours)").font(.system(size: 15)).bold()
                        Text("H").font(.caption).foregroundColor(.gray)
                        Text("\(summary.totalMinutes)").font(.system(size: 15)).bold()
                        Text("M").font(.caption).foregroundColor(.gray)
                    }
                    .foregroundColor(.white)
                }
            }
            
            HStack {
                Text("Weekly Trend: ")
                    .foregroundColor(.gray) +
                Text(summary.weeklyTrend)
                    .foregroundColor(.white)
                    .bold()
                
                Spacer()
            }
            .font(.caption)
        }
    }
    
    private func statColumn(label: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value).font(.system(size: 15)).bold()
                Text(unit).font(.system(size: 15)).foregroundColor(.gray)
            }
            .foregroundColor(.white)
        }
    }
}
