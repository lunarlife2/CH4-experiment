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
		
		Text("Zone 1: \(zones[0].min)-\(zones[0].max)")
		Text("Zone 2: \(zones[1].min)-\(zones[1].max)")
		Text("Zone 3: \(zones[2].min)-\(zones[2].max)")
		Text("Zone 4: \(zones[3].min)-\(zones[3].max)")
		Text("Zone 5: \(zones[4].min)-\(zones[4].max)")
		Text("Done")
		
		Button {
			settings.saveZones(zones)
			settings.onboarding = true
		} label: {
			Text("Next")
		}
	}
}
