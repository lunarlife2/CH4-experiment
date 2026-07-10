//
//  EndRunningView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI
import HealthKit

struct EndRunningView: View {
//    @Environment(RunningSessionManager.self) private var sessionManager
    @Environment(\.dismiss) var dismiss
    @State private var sessionManager = RunningSessionManager.shared
    
    let finalTimeInZone: TimeInterval
    let selectedZone: Int
    
    var body: some View {
        let _ = print("🔵 EndRunningView body - finalTimeInZone:", finalTimeInZone, "zone:", selectedZone)
        VStack (alignment: .center) {
            Text("Well Done!")
                .font(.system(size: 23, weight: .semibold))
            
            Text("You maintain in Zone \(selectedZone) for \(sessionManager.formatDurationText(finalTimeInZone))!")
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                
            }
        }
    }
}

#Preview {
    EndRunningView(finalTimeInZone: 1200, selectedZone: 1)
        .environment(RunningSessionManager.shared)
}
