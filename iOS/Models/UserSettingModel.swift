//
//  UserSettingModel.swift
//  CH4
//
//  Created by Averina on 08/07/26.
//

import Foundation
import SwiftUI
import Combine

class UserSettings: ObservableObject {
    @AppStorage("age") var age = 0
    @AppStorage("onboarding") var onboarding = false
    @AppStorage("zone1Min") var zone1Min = 0
    @AppStorage("zone1Max") var zone1Max = 0
    @AppStorage("zone2Min") var zone2Min = 0
    @AppStorage("zone2Max") var zone2Max = 0
    @AppStorage("zone3Min") var zone3Min = 0
    @AppStorage("zone3Max") var zone3Max = 0
    @AppStorage("zone4Min") var zone4Min = 0
    @AppStorage("zone4Max") var zone4Max = 0
    @AppStorage("zone5Min") var zone5Min = 0
    @AppStorage("zone5Max") var zone5Max = 0
    
    func saveZones(_ zones: [HeartRateZone]) {
        zone1Min = zones[0].min
        zone1Max = zones[0].max
        
        zone2Min = zones[1].min
        zone2Max = zones[1].max
        
        zone3Min = zones[2].min
        zone3Max = zones[2].max
        
        zone4Min = zones[3].min
        zone4Max = zones[3].max
        
        zone5Min = zones[4].min
        zone5Max = zones[4].max
        
        ConnectivityManager.shared.sendZonesToWatch(self)
    }
}
