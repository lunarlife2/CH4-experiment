//
//  PermissionsView.swift
//  CH4
//
//  Created by Averina on 07/07/26.
//

import SwiftUI
import Combine

struct PermissionsView: View {
	@StateObject var vm = OnboardingViewModel()
	@State private var healthManager = HealthKitManager()
	
	var body: some View {
		Text("Welcome to permissions")
		
		Button {
			healthManager.requestAuthorization()
		} label: {
			Text("Request Permissions")
		}
		
		Button {
			vm.next()
		} label: {
			Text("Next")
		}


	}
		
}

#Preview {
	PermissionsView()
}
