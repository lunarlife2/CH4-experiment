//
//  CalorieViewModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 09/07/26.
//

import Foundation
import Observation


@Observable
final class CalorieViewModel {

    private let healthManager: HealthKitManager

    init(healthManager: HealthKitManager) {
        self.healthManager = healthManager
    }

    var totalCalories: Int {
        Int(healthManager.caloriesBurned)
    }

}
