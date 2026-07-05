//
//  OnboardingViewModel.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 05/07/26.
//

import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 1
    let model = OnboardingModel()

    func continueTapped() {
       //logic pindah halaman / navigasi ke sini
    }

    func dotColor(for page: Int) -> Color {
        currentPage == page ? .orange : .white.opacity(0.4)
    }
}
