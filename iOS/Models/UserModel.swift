//
//  UserModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import Foundation

struct UserProfile: Identifiable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var avatarURL: URL?

    var age: Int?
    var heightCM: Double?
    var weightKG: Double?
    var maxHeartRate: Int?

    var languageCode: String // "en" or "id"

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        avatarURL: URL? = nil,
        age: Int? = nil,
        heightCM: Double? = nil,
        weightKG: Double? = nil,
        maxHeartRate: Int? = nil,
        languageCode: String = "en"
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.age = age
        self.heightCM = heightCM
        self.weightKG = weightKG
        self.maxHeartRate = maxHeartRate
        self.languageCode = languageCode
    }

    // Computed property for max heart rate default (220 - age)
    var estimatedMaxHeartRate: Int? {
        guard let age else { return nil }
        return 220 - age
    }
}
