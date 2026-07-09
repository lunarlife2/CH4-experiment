//
//  SelectedZones.swift
//  watch Watch App
//
//  Created by Yimei Winata on 08/07/26.
//

import Foundation

struct SelectedZones {
    let zone: Int
    let max: Int
    let min: Int

    init(zone: Int) {
        self.zone = zone
        
        let defaults = UserDefaults.standard
        
        switch zone {
        case 1:
            self.max = defaults.integer(forKey: "zone1Max")
            self.min = defaults.integer(forKey: "zone1Min")
            
        case 2:
            self.max = defaults.integer(forKey: "zone2Max")
            self.min = defaults.integer(forKey: "zone2Min")
            
        case 3:
            self.max = defaults.integer(forKey: "zone3Max")
            self.min = defaults.integer(forKey: "zone3Min")
            
        case 4:
            self.max = defaults.integer(forKey: "zone4Max")
            self.min = defaults.integer(forKey: "zone4Min")
            
        case 5:
            self.max = defaults.integer(forKey: "zone5Max")
            self.min = defaults.integer(forKey: "zone5Min")
            
        default:
            self.max = defaults.integer(forKey: "zone1Max")
            self.min = defaults.integer(forKey: "zone1Min")
        }
    }
}
