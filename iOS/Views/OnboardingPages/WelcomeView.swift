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
		Text("Welcome to SwiftUI")
			.foregroundStyle(Color.accentDark)
		
		Button("Next") {
			vm.next()
		}
	}
}

#Preview {
	WelcomeView()
}
