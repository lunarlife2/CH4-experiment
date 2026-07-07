//
//  TabItem.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import Foundation

enum Tab: String, CaseIterable {
    case home = "Home"
    case run = "Run"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .run: return "figure.run"
        case .profile: return "person.fill"
        }
    }
}
