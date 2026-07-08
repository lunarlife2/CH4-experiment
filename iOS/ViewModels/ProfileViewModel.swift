//
//  ProfileViewModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//


import Foundation
import Observation

@Observable
class ProfileViewModel {

    var name: String
    var email: String
    var avatarURL: URL?
//    var selectedLanguage: AppLanguage

    private let healthManager: HealthKitManager
//    private let localizationManager: LocalizationManager

    init(
        name: String,
        email: String,
        avatarURL: URL? = nil,
        healthManager: HealthKitManager,
//        localizationManager: LocalizationManager = .shared
    ) {
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.healthManager = healthManager
//        self.localizationManager = localizationManager
//        self.selectedLanguage = localizationManager.currentLanguage
    }

    // MARK: - Actions

    func onAppear() {
        healthManager.requestAuthorization()
    }

//    func selectLanguage(_ language: AppLanguage) {
//        selectedLanguage = language
//        localizationManager.currentLanguage = language
//    }

    var ageText: String {    
        healthManager.age.map { "\($0)" } ?? "--"
    }

    var heightText: String {
        healthManager.heightCM.map { String(format: "%.0f", $0) } ?? "--"
    }

    var weightText: String {
        healthManager.weightKG.map { String(format: "%.0f", $0) } ?? "--"
    }

    var maxHeartRateText: String {
        healthManager.maxHeartRateBPM.map { "\($0)" } ?? "--"
    }
}
