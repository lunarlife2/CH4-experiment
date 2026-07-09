//
//  GetStartedView.swift
//  CH4
//
//  Created by Averina on 08/07/26.
//

import SwiftUI
import Combine

struct GetStartedView: View {
	@StateObject var vm = OnboardingViewModel()
	
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
			
			VStack (spacing: 10) {
				HStack (spacing: 0) {
					Text("Welcome to Ran Up")
						.font(.system(size: 48, weight: .semibold))
						.multilineTextAlignment(.leading)
						.foregroundStyle(Color.white)
						.frame(maxWidth: .infinity, alignment: .leading)
						
					Image(.runningMan)
						.resizable()
						.scaledToFit()
						.frame(width: 130, height: 130)
				}
				.frame(height: 130)
				.padding()
				
				
				Text("Let's Run, Sync Heart Rate, Track Progress")
					.font(.system(size: 16, weight: .semibold))
					.foregroundStyle(Color.white)
					.padding()
				
				Image(.watch)
					.resizable()
					.scaledToFit()
					.padding(.vertical)
				
				Text("Your personal running companion to understand your heart rate, stay active, and build healthier habits")
					.font(.system(size: 16, weight: .semibold))
					.foregroundStyle(Color.white)
					.multilineTextAlignment(.center)
					.padding()
				
				Button {
					vm.next()
				} label: {
					Text("Get Started")
						.frame(width: 225)
						.font(.system(size: 22, weight: .semibold))
						.padding(.vertical, 10)
				}
				.buttonStyle(.glassProminent)
				.tint(Color.secondaryNormal)
				.padding()
			}
			.padding()
		}
	}
}

#Preview {
	GetStartedView()
}
