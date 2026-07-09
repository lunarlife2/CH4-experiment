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
                
                ZoneProgressRing(progress: viewModel.targetZoneProgress,
                                 color: viewModel.targetZoneColor,
                                 percentageLabel: viewModel.targetZonePercentageLabel,
                                 zoneName: viewModel.targetZoneName,
                                 bpmRangeLabel: viewModel.targetZoneRangeLabel
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                
                ZonesGuideLegend(zones: viewModel.zones)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
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

private struct ZoneProgressRing: View {
    let progress: Double // 0...1
    let color: Color
    let percentageLabel: String
    let zoneName: String
    let bpmRangeLabel: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 18)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
            
            VStack(spacing: 6) {
                Text(percentageLabel)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                Text(zoneName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                Text(bpmRangeLabel)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(width: 220, height: 220)
    }
}

private struct ZonesGuideLegend: View {
    let zones: [ZoneDisplayItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Zones Guide (BPM)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 2)
            
            ForEach(zones) { zone in
                (
                    Text("\(zone.colorName) Zone (\(zone.name)): ")
                        .font(.system(size: 16, weight: .semibold))
                    + Text(zone.bpmRangeLabel)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.85))
                )
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
