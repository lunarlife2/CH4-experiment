//
//  ContentView.swift
//  RWhealthkit
//
//  Created by Ni Komang Ayu Juliana on 29/06/26.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = HealthKitManager()
    var body: some View {
        VStack {
            Text("HealthKit App")
                .font(.largeTitle)
            Text(manager.authStatus)
                .font(.caption)
        }
        .padding()
        
        VStack{
            HStack{
                ZStack{
                    Color(uiColor: .systemGray6)
                        .cornerRadius(15)
                    VStack {
                        HStack (alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Today Steps")
                                    .font(.system(size:16))
                                
                            }
                        }
                        
                        Text("\(manager.stepCount)")
                            .font(.system(size: 50))
                    }
                    
                }
                ZStack{
                    Color(uiColor: .systemGray6)
                        .cornerRadius(15)
                    VStack {
                        HStack (alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Today Calories")
                                    .font(.system(size:16))
                                
                            }
                        }

                        Text("\(manager.activeEnergyBurned)")
                            .font(.system(size: 50))
                    }
                    
                }
            }
            VStack{
                Button("Requested Permission"){
                    Task{await manager.requestAuthorization()}
                }
                .buttonStyle(.borderedProminent)
                
                Button("Refresh Steps"){
                    Task{await manager.fetchTodayStepCount()}
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Refresh Calories"){
                    Task{await manager.fetchTodayEnergyBurned}
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            
                
                Button("Add calories 10cal"){
                    Task{await manager.addTodayEnergyBurned(calorie: 10)}
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                
                
            }
            
        }
    }
}

#Preview {
    ContentView()
}

