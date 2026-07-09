//
//  ZonePickerView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 05/07/26.
//

import SwiftUI
import HealthKit
import WorkoutKit

struct ZonePickerView: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    @State private var selectedZone = 1
    let zone = [1, 2, 3, 4, 5]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Choose Your Zone:")
                    .fontWeight(.semibold)
                    .font(.system(size: 14))
                
                Picker("", selection: $selectedZone) {
                    ForEach(zone, id: \.self) { zone in
                        Text("\(zone)").tag(zone)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 15)
                .onChange(of: selectedZone) { _, newValue in
                    sessionManager.selectedZones = SelectedZones(zone: newValue)
                }
                
                NavigationLink {
                    LoadingView()
                        .environment(sessionManager)
                } label: {
                    Text("Start")
                        .foregroundStyle(Color.white)
                }
                
                .tint(Color.secondaryNormal)
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
            .onAppear {
                sessionManager.selectedZones = SelectedZones(zone: selectedZone)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(sessionManager.runningType.name)
                        .font(.system(size: 14))
                        .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    ZonePickerView()
        .environment(RunningSessionManager())
}
