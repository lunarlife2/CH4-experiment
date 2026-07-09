//
//  LoadingView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 05/07/26.
//

import SwiftUI
import HealthKit

struct LoadingView: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    @State private var progress: CGFloat = 1
    @State private var displayText = "Ready!"
    @State private var isFinished = false
    private let totalTime = 2
    
        
    var body: some View {
        NavigationStack{
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 17)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.secondaryNormal, style: StrokeStyle(lineWidth: 17, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: progress)
                
                Text(displayText)
                    .bold()
                    .animation(nil, value: displayText)
                    .foregroundStyle(Color.secondaryNormal)
                
            }
            .onAppear {
                startCountDown()
            }
            .task {
                await sessionManager.startSession(
                    activityType: sessionManager.runningType.activity,
                    locationType: sessionManager.runningType.location
                )
            }
            .navigationDestination(isPresented: $isFinished) {
                PaginationTabView()
                    .navigationBarBackButtonHidden()
                    .environment(sessionManager)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func startCountDown() {
        for tick in 1...totalTime {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(tick) ) {
                if tick == 2 {
                    displayText = "Go!"
                }
                progress = CGFloat(totalTime-tick)/CGFloat(totalTime)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalTime) + 1){
            isFinished = true
        }
    }
    
}

#Preview {
    LoadingView()
        .environment(RunningSessionManager())
}
