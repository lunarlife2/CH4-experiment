//
//  CH4App.swift
//  CH4
//
//  Created by Averina on 26/06/26.
//

import SwiftUI

@main
struct iOSApp: App {
	@StateObject private var settings = UserSettings()

	var body: some Scene {
		WindowGroup {
			RootView()
				.environmentObject(settings)
		}
	}
}
