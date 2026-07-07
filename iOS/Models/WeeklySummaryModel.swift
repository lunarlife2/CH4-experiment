//
//  WeeklySummaryModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import Foundation
 
struct WeeklySummary {
    var totalDistanceKm: Double = 0
    var avgPaceFormatted: String = "00:00"
    var totalHours: Int = 0
    var totalMinutes: Int = 0
    var weeklyTrend: String = "Stable"   // "Increasing" / "Decreasing" / "Stable"
}
