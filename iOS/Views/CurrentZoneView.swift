//
//  CurrentZoneView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 09/07/26.
//

import SwiftUI

struct CurrentZoneView: View {
    var viewModel: ZoneViewModel
    var onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CloseButtonHeader(title: "Current Zone", onClose: onClose)

                ZoneBarChart(zones: viewModel.zones, maxDuration: viewModel.maxDurationMinutes)
                    .frame(height: 220)

                ZonesGuideLegend(zones: viewModel.zones)

                HStack(alignment: .center, spacing: 0) {
                    ZoneInfoColumn(title: "Current Target", value: viewModel.targetZoneName, subValue: viewModel.targetZoneRangeLabel)
                    Divider().overlay(Color.white.opacity(0.2))
                    ZoneInfoColumn(title: "Zone Time", value: viewModel.zoneTimeFormatted)
                    Divider().overlay(Color.white.opacity(0.2))
                    ZoneInfoColumn(title: "Avarage BPM", value: "\(viewModel.currentBPM)")
                }
                .frame(height: 90)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}


private struct ZoneBarChart: View {
    let zones: [ZoneDisplayItem]
    let maxDuration: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 18) {
            ForEach(zones) { zone in
                VStack(spacing: 6) {
                    Text("Dur: \(zone.durationMinutes)m")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))

                    RoundedRectangle(cornerRadius: 8)
                        .fill(zone.color)
                        .frame(height: barHeight(for: zone.durationMinutes))

                    Text(zone.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func barHeight(for minutes: Int) -> CGFloat {
        let minHeight: CGFloat = 20
        let maxHeight: CGFloat = 160
        guard maxDuration > 0 else { return minHeight }
        return minHeight + CGFloat(minutes) / CGFloat(maxDuration) * (maxHeight - minHeight)
    }
}

private struct ZonesGuideLegend: View {
    let zones: [ZoneDisplayItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Zones Guide (BPM)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 2)

            ForEach(zones) { zone in
                (
                    Text("\(zone.colorName) Zone (\(zone.name)): ")
                        .foregroundColor(zone.color)
                        .fontWeight(.semibold)
                    + Text(zone.bpmRangeLabel)
                        .foregroundColor(.white.opacity(0.85))
                )
                .font(.system(size: 13))
            }
        }
    }
}


private struct ZoneInfoColumn: View {
    let title: String
    let value: String
    var subValue: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            if let subValue {
                Text(subValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }
}



#Preview {
    CurrentZoneView(
        viewModel: ZoneViewModel(healthManager: HealthKitManager()),
        onClose: {}
    )
}
