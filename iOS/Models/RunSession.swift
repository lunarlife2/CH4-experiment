//
//  RunSession.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import Foundation

struct RunSession: Identifiable {
    let id = UUID()
    let date: Date
    let distanceKm: Double
    let paceFormatted: String // "5:28 /KM"
}

