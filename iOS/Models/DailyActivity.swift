//
//  DailyActivity.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 06/07/26.
//

import Foundation

struct DailyActivity: Identifiable {
    let id = UUID()
    let day: String          // "Sun", "Mon", etc
    let date: Date
    let indoorScore: Double  // indoor running
    let outdoorScore: Double // outdoor running
}
