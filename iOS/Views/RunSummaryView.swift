//
//  RunSummaryView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//

import SwiftUI
import Combine

struct RunSummaryView: View {
    @StateObject private var viewModel: RunSummaryViewModel

    var onDismiss: () -> Void

    init(
        runType: RunType,
        distanceKm: Double,
        duration: TimeInterval,
        averagePace: TimeInterval,
        caloriesBurned: Double,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: RunSummaryViewModel(
            runType: runType,
            distanceKm: distanceKm,
            duration: duration,
            averagePace: averagePace,
            caloriesBurned: caloriesBurned
        ))
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                header
                summaryCard
                Spacer()
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            if viewModel.showNotif {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                NotifChipView(type: viewModel.notifType) {
                    viewModel.dismissNotif()
                }
            }
        }
        .onAppear {
            viewModel.onFinished = onDismiss
        }
    }


    private var header: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text("Ran Up")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Circle()
                    .strokeBorder(Color(hex: "C35A1D"), lineWidth: 2)
                    .background(Circle().fill(Color.gray.opacity(0.3)))
                    .frame(width: 87, height: 87)
                 .overlay(Image("profile").resizable().scaledToFill().clipShape(Circle()))
                 .shadow(color: .orange.opacity(0.7), radius: 20)


            }

            LinearGradient(
                colors: [.blue, .green, .yellow, .orange, .red],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 4)
            .clipShape(Capsule())
        }
    }


    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(viewModel.runType == .outdoor ? "Outdoor Run Summary" : "Indoor Run Summary")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 16) {
                Image(systemName: viewModel.runType == .outdoor ? "figure.run" : "figure.run.treadmill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .foregroundColor(Color.white)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Distance")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", viewModel.distanceKm))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        Text("km")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                Spacer()
            }

            summaryRow(title: "Duration", value: viewModel.durationFormatted, unit: nil)
            summaryRow(title: "Average Pace (min/km)", value: viewModel.averagePaceFormatted, unit: "min/km")
            summaryRow(title: "Calories Burned", value: "\(Int(viewModel.caloriesBurned))", unit: "kcal")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.16, green: 0.09, blue: 0.05))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func summaryRow(title: String, value: String, unit: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                if let unit {
                    Text(unit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }


    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.cancelTapped()
            } label: {
                Text("Cancel")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .glassEffect(.regular.tint(Color(red: 0.35, green: 0.12, blue: 0.05)), in: Capsule())
            .disabled(viewModel.isSaving)

            Button {
                viewModel.saveTapped()
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.black)
                    }
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .glassEffect(.regular.tint(Color.white.opacity(0.9)), in: Capsule())
            .disabled(viewModel.isSaving)
        }
        .padding(.bottom, 24)
    }
}

#Preview("Indoor") {
    RunSummaryView(
        runType: .indoor,
        distanceKm: 2.5,
        duration: 22 * 60 + 15,
        averagePace: 8 * 60 + 54,
        caloriesBurned: 210,
        onDismiss: {}
    )
}

#Preview("Outdoor") {
    RunSummaryView(
        runType: .outdoor,
        distanceKm: 5.2,
        duration: 31 * 60 + 40,
        averagePace: 6 * 60 + 5,
        caloriesBurned: 410,
        onDismiss: {}
    )
}
