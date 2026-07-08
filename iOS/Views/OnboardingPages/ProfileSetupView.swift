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
		Text("Welcome to profile setup")

		Stepper(value: $settings.age, in: 0...120) {
			HStack {
				Text("Age")

				//Spacer()

				TextField(
					"Age",
					value: $settings.age,
					format: .number
				)
				.keyboardType(.numberPad)
				.multilineTextAlignment(.trailing)
				.frame(width: 50)
			}
		}
		.padding()

		Button {
			vm.next()
		} label: {
			Text("Next")
		}
	}
}

#Preview {
	ProfileSetupView()
}
