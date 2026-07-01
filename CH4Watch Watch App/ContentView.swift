//
//  ContentView.swift
//  tesWatch2 Watch App
//
//  Created by Yimei Winata on 23/06/26.
//

import SwiftUI
import WatchConnectivity
import UserNotifications
import WatchKit
import Combine
import AVFoundation
import HealthKit

struct ContentView: View {
    
    @StateObject private var shared = ConnectivityManager()
    @State private var workoutSession: HKWorkoutSession?
    @State private var workoutBuilder: HKLiveWorkoutBuilder?
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    @State private var value = 0
    
    
    private let synthesizer = AVSpeechSynthesizer()
    @StateObject private var monitor = HeartRateMonitor()
    
    
    var body: some View {
        VStack {
            Button("Start") {
                Task {
                    print("Uda kepencet")
                    startHaptic(text: "aku ayuk", synthesizer: synthesizer)
                }
            }
            
            Button("1x Loop Haptics"){
                Task {
                    print("Uda kepencet Haptics 1")
                    hapticLoop(loops: 1)
                }
            }
            
            Button("2x Loop Haptics"){
                Task {
                    print("Uda kepencet Haptics 2")
                    hapticLoop(loops: 2)
                }
            }
            
            HStack{
                Text("\(monitor.currentBPM)")
                    .fontWeight(.regular)
                    .font(.system(size: 70))
                
                Text("BPM")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                    .padding(.bottom, 28.0)
                
                Spacer()
                
            }
        }
        .padding()
        .onAppear{
            monitor.start()
        }
    }
}



#Preview {
    ContentView()
}
