//
//  LoadingView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 05/07/26.
//

import SwiftUI

struct LoadingView: View {
    @State private var progress: CGFloat = 1
    @State private var displayText = "Ready!"
    private let totalTime = 2
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 17)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 17, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)
            
            Text(displayText)
                .bold()
                .animation(nil, value: displayText)
                
        }
        .onAppear {
            startCountDown()
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
    }
    
}

#Preview {
    LoadingView()
}
