//
//  ViewModel.swift
//  tesWatch
//
//  Created by Yimei Winata on 26/06/26.
//

import AlarmKit
import SwiftUI

@Observable class ViewModel{
    @ObservationIgnored private let alarmManager = AlarmManager.shared
    @MainActor var alarmMaps = [UUID: (Alarm, LocalizedStringResource)]()
    
    private func requestAuthorization() async -> Bool {
        switch alarmManager.authorizationState {
        case .notDetermined:
            do {
                let state = try await alarmManager.requestAuthorization()
                return state == .authorized
            } catch {
                print("Error occurred while requesting authorization: \(error)")
                return false
            }
        case .denied: return false
        case .authorized: return true
        @unknown default: return false
        }
    }
}


