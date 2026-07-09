//
//  WelcomeView.swift
//  CH4
//
//  Created by Averina on 07/07/26.
//

import SwiftUI

struct WelcomeView: View {
	@StateObject var vm = OnboardingViewModel()

	var body: some View {
		VStack(spacing: 0) {
			Spacer()

			// Running logo, sits in the upper-middle area
			Image(.welcomeLogo)
				.resizable()
				.scaledToFit()
				.frame(width: 400)
				.offset(y: 70)

			// Bottom oval card with content overlaid on top of it
			ZStack {
				Image(.welcomeProp)
					.offset(y: 50)

				VStack(spacing: 20) {
					Spacer()
						.frame(height: 120)  // pushes content below the "RAN UP" text baked into the image

					Text("YOUR HEALTH, YOUR PACE, YOUR JOURNEY")
						.foregroundStyle(Color.white)
						.font(.system(size: 20, weight: .semibold))
						.multilineTextAlignment(.center)
						.padding(.horizontal, 40)
						.padding(.vertical, 10)

					Button {
						vm.next()
					} label: {
						Text("Continue")
							.frame(width: 225)
							.font(.system(size: 22, weight: .semibold))
							.padding(.vertical, 10)
					}
					.buttonStyle(.glassProminent)
					.tint(Color.secondaryNormal)
				}
				//.background(Color.red.opacity(0.1))
			}
			.frame(maxWidth: .infinity)
			.ignoresSafeArea(edges: .bottom)
			//.background(Color.white.opacity(0.3))
		}
		.background(
			Image(.bgWelcomeOnboarding)
				.resizable()
				.scaledToFill()
				.ignoresSafeArea()
		)

	}
}

#Preview {
	WelcomeView()
}
