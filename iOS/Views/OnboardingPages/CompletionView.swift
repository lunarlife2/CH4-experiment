//
//  CompletionView.swift
//  CH4
//
//  Created by Averina on 07/07/26.
//

import SwiftUI

struct CompletionView: View {
	@EnvironmentObject var settings: UserSettings

	var body: some View {
		let zones = HeartRateCalculator.calculateZones(age: settings.age)
		let zoneColors: [Color] = [.blue, .green, .yellow, .orange, .red]
		
		ZStack {
			LinearGradient(
				stops: [
					Gradient.Stop(color: Color(hex: "275957"), location: 0.0),  // Starts at the very top
					Gradient.Stop(color: Color(hex: "143534"), location: 0.24),  // Quick transition to pink at 25%
					Gradient.Stop(color: Color(hex: "0B1313"), location: 1.0),  // Stretches smoothly to orange at 100%
				],
				startPoint: .top,
				endPoint: .bottom
			)
			.ignoresSafeArea()

			VStack(spacing: 10) {
				Text(
					"Here are your personal heart rate zones!"
				)
				.font(.system(size: 40, weight: .semibold))
				.foregroundStyle(Color.white)
				.multilineTextAlignment(.center)
				.padding()

//				Text(
//					"penjelasan zones."
//				)
//				.font(.system(size: 16, weight: .semibold))
//				.foregroundStyle(Color.white)
//				.multilineTextAlignment(.center)
//				.padding()

				VStack (spacing: 60) {
					ForEach(1...5, id: \.self) { zone in
						HStack (spacing: 50) {
							HStack {
								RoundedRectangle(cornerRadius: 5)
									.frame(width: 10, height: 30)
									.foregroundStyle(zoneColors[zone-1])
								Text(
									"Zone \(zone): "
								)

							}
							Text("\(zones[zone - 1].min)-\(zones[zone - 1].max) BPM")
						}
						.background(
							RoundedRectangle(cornerRadius: 10)
								.frame(width: 270, height: 60)
								.foregroundStyle(Color.gray.opacity(0.3))
						)
					}
				}
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(Color.white)
				.multilineTextAlignment(.center)
				.padding()

				Button {
					settings.saveZones(zones)
					settings.onboarding = true
				} label: {
					Text("Next")
						.frame(width: 225)
						.font(.system(size: 22, weight: .semibold))
						.padding(.vertical, 10)
				}
				.buttonStyle(.glassProminent)
				.tint(Color.secondaryNormal)
				.padding()
			}
		}
	}
}

#Preview {
	CompletionView()
		.environmentObject(UserSettings())
}
