//
//  RunSummaryViewModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//

import SwiftUI
import Combine

@MainActor
final class RunSummaryViewModel: ObservableObject {

    enum NotifType {
        case saved
        case notSaved

        var message: String {
            switch self {
            case .saved: return "Your running history has been saved"
            case .notSaved: return "Your running history was not saved"
            }
        }

        var tintColor: Color {
            switch self {
            case .saved: return Color.accentNormal
            case .notSaved: return Color.primaryNormal  
            }
        }
    }


    let runType: RunType
    let distanceKm: Double
    let duration: TimeInterval
    let averagePace: TimeInterval
    let caloriesBurned: Double


    @Published var showNotif: Bool = false
    @Published var notifType: NotifType = .saved
    @Published var isSaving: Bool = false

    var onFinished: (() -> Void)?

    init(
        runType: RunType,
        distanceKm: Double,
        duration: TimeInterval,
        averagePace: TimeInterval,
        caloriesBurned: Double
        
    ) {
        self.runType = runType
        self.distanceKm = distanceKm
        self.duration = duration
        self.averagePace = averagePace
        self.caloriesBurned = caloriesBurned
    }

    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var averagePaceFormatted: String {
        let minutes = Int(averagePace) / 60
        let seconds = Int(averagePace) % 60
        return String(format: "%d.%02d", minutes, seconds)
    }

    func cancelTapped() {
        notifType = .notSaved
        presentNotif()
    }

    func saveTapped() {
        guard !isSaving else { return }
        isSaving = true

        HealthKitManager.shared.saveRun(
            type: runType,
            distanceKm: distanceKm,
            duration: duration,
            calories: caloriesBurned
        ) { [weak self] success in
            guard let self else { return }
            self.isSaving = false
            self.notifType = success ? .saved : .notSaved
            self.presentNotif()
        }
    }

    func dismissNotif() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            showNotif = false
        }
        onFinished?()
    }

   func presentNotif() {
        showNotif = true
    }
}
