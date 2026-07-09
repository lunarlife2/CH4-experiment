//
//  ProfileSetupView.swift
//  CH4
//
//  Created by Averina on 07/07/26.
//

import SwiftUI

struct ProfileSetupView: View {
	@StateObject var vm = OnboardingViewModel()
	@EnvironmentObject var settings: UserSettings

	var body: some View {
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
					"Tailor your experience by customizing your heart rate zones"
				)
				.font(.system(size: 40, weight: .semibold))
				.foregroundStyle(Color.white)
				.multilineTextAlignment(.center)
				.padding()

				Text(
					"We need your age to calculate your personal heart rate zones."
				)
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(Color.white)
				.multilineTextAlignment(.center)
				.padding()
				
				Picker("Select your age", selection: $settings.age) {
					// Defines the bounds from 18 to 99 inclusive
					ForEach(0...99, id: \.self) { number in
						Text("\(number)")
							.foregroundStyle(Color.white)
					}
				}
				.pickerStyle(.wheel)  // Renders as a scrollable wheel
				.frame(width: 250, height: 150)
				.foregroundStyle(Color.secondaryLight)
				.background(Color.white.opacity(0.2))
				.background(RoundedRectangle(cornerRadius: 12)
					.strokeBorder(Color.secondaryNormal, lineWidth: 3))
				.padding()

				Spacer()

				Button {
					vm.next()
				} label: {
					Text("Next")
						.frame(width: 225)
						.font(.system(size: 22, weight: .semibold))
						.padding(.vertical, 10)
				}
				.disabled(settings.age == 0)
				.buttonStyle(.glassProminent)
				.tint(Color.secondaryNormal)
			}
			.padding()
		}
	}
}

#Preview {
	ProfileSetupView()
		.environmentObject(UserSettings())
}
