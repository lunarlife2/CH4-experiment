//
//  ZoneViewModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 09/07/26.
//

import SwiftUI
import Observation

struct ZoneDisplayItem: Identifiable {
    let id = UUID()
    let zone: Int
    let min: Int
    let max: Int
    let durationMinutes: Int

    let name: String
    let colorName: String
    let color: Color
    let bpmRangeLabel: String
}


@Observable
final class ZoneViewModel {

    private let healthManager: HealthKitManager

    init(healthManager: HealthKitManager) {
        self.healthManager = healthManager
    }

    private var age: Int {
        healthManager.age ?? 25
    }


    var zones: [ZoneDisplayItem] {
        let computedZones = HeartRateCalculator.calculateZones(age: age)

        let durations = [10, 8, 20, 10, 5]

        return computedZones.enumerated().map { i, model in
            ZoneDisplayItem(
                zone: model.zone,
                min: model.min,
                max: model.max,
                durationMinutes: i < durations.count ? durations[i] : 0,
                name: "Zone \(model.zone)",
                colorName: Self.colorName(forZone: model.zone),
                color: Self.color(forZone: model.zone),
                bpmRangeLabel: Self.bpmRangeLabel(min: model.min, max: model.max, zone: model.zone)
            )
        }
    }

    
    var currentBPM: Int {
        Int(healthManager.avgHeartRate)
    }

    var currentZoneIndex: Int {
        let computedZones = HeartRateCalculator.calculateZones(age: age)
        return Self.zoneIndex(forBPM: currentBPM, in: computedZones)
    }

    var targetZone: ZoneDisplayItem? {
        zones.first(where: { $0.zone == currentZoneIndex })
    }

    var targetZoneColor: Color {
        targetZone?.color ?? Color(hex: "3B82F6")
    }

    var targetZoneProgress: Double {
        guard let target = targetZone else { return 0 }
        let range = Double(target.max - target.min)
        guard range > 0 else {
            return currentBPM >= target.min ? 1.0 : 0.0
        }
        let progress = Double(currentBPM - target.min) / range
        return min(max(progress, 0), 1)
    }

    var targetZonePercentageLabel: String {
        "\(Int((targetZoneProgress * 100).rounded()))%"
    }
    
    var zoneTimeFormatted: String {
        "12:45"
    }

    var targetZoneName: String {
        zones.first(where: { $0.zone == currentZoneIndex })
            .map { "\($0.colorName) Zone" } ?? ""
    }

    var targetZoneRangeLabel: String {
        zones.first(where: { $0.zone == currentZoneIndex })
            .map { "(\($0.bpmRangeLabel))" } ?? ""
    }

    var maxDurationMinutes: Int {
        max(zones.map(\.durationMinutes).max() ?? 1, 1)
    }

    var sliderProgress: CGFloat {
        guard zones.count > 1 else { return 0 }
        return CGFloat(currentZoneIndex - 1) / CGFloat(zones.count - 1)
    }


    private static func colorName(forZone zone: Int) -> String {
        switch zone {
        case 1: return "Blue"
        case 2: return "Green"
        case 3: return "Yellow"
        case 4: return "Orange"
        default: return "Red"
        }
    }

    private static func color(forZone zone: Int) -> Color {
        switch zone {
        case 1: return Color(hex: "3B82F6")
        case 2: return Color(hex: "22C55E")
        case 3: return Color(hex: "F5C518")
        case 4: return Color(hex: "F08A1E")
        default: return Color(hex: "E4483C")
        }
    }

    private static func bpmRangeLabel(min: Int, max: Int, zone: Int) -> String {
        zone == 5 ? ">\(min) bpm" : "\(min)-\(max) bpm"
    }

    private static func zoneIndex(forBPM bpm: Int, in zones: [HeartRateZone]) -> Int {
        if let match = zones.first(where: { bpm >= $0.min && bpm <= $0.max }) {
            return match.zone
        }
        if let last = zones.last, bpm > last.max { return last.zone }
        return zones.first?.zone ?? 1
    }
}
