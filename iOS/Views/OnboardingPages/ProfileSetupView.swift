//
//  ProfileSetupView.swift
//  CH4
//
//  Created by Averina on 07/07/26.
//

import SwiftUI

struct ProfileSetupView: View {
	@StateObject var vm = OnboardingViewModel()
	@State var 
	
	var body: some View {
		Text("Welcome to profile setup")
		
		
		
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
