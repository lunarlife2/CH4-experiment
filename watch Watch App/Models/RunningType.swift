//
//  RunningType.swift
//  watch Watch App
//
//  Created by Yimei Winata on 05/07/26.
//

import Foundation
import HealthKit
import WorkoutKit

struct RunningType: Identifiable {
    let id: UUID = UUID()
    let name: String
    let icon: String
    let activity: HKWorkoutActivityType
    let location: HKWorkoutSessionLocationType
}

extension RunningType {
    static let running: [RunningType] = [
        RunningType(
            name: "Outdoor Run",
            icon: "figure.run",
            activity: .running,
            location: .outdoor
        ),
        RunningType(
            name: "Indoor Run",
            icon: "figure.run.treadmill",
            activity: .running,
            location: .indoor
        ),
    ]
}
