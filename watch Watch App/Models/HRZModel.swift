//
//  HRZModel.swift
//  CH4
//
//  Created by Averina on 07/07/26.
//
import Foundation

struct HeartRateZone {
	let zone: Int
	let min: Int
	let max: Int
}

//struct HeartRateCalculator {
//
//	static func calculateZones(age: Int) -> [HeartRateZone] {
//		let maxHR = 220 - age
//
//		return [
//			HeartRateZone(zone: 1,
//						  min: Int(Double(maxHR) * 0.50),
//						  max: Int(Double(maxHR) * 0.60)),
//
//			HeartRateZone(zone: 2,
//						  min: Int(Double(maxHR) * 0.60),
//						  max: Int(Double(maxHR) * 0.70)),
//
//			HeartRateZone(zone: 3,
//						  min: Int(Double(maxHR) * 0.70),
//						  max: Int(Double(maxHR) * 0.80)),
//
//			HeartRateZone(zone: 4,
//						  min: Int(Double(maxHR) * 0.80),
//						  max: Int(Double(maxHR) * 0.90)),
//
//			HeartRateZone(zone: 5,
//						  min: Int(Double(maxHR) * 0.90),
//						  max: maxHR)
//		]
//	}
//}
