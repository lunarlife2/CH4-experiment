//
//  RunView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI
import Foundation

struct RunView: View {
    @State private var selectedType: RunType?
    @State private var step: RunSetupStep = .selectType
    @State private var selectedZone: Int = 2
    
    var onStartRun: (RunType, Int) -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Ready to Run")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 60)

                if step == .selectType {
                    RunTypeButton(
                        backgroundImageName: "buttonrun",
                        sfSymbolName: "figure.run.treadmill",
                        title: "Indoor",
                        isSelected: selectedType == .indoor
                    ) {
                        selectType(.indoor)
                    }
                    
                    RunTypeButton(
                        backgroundImageName: "buttonrun",
                        sfSymbolName: "figure.run",
                        title: "Outdoor",
                        isSelected: selectedType == .outdoor
                    ) {
                        selectType(.outdoor)
                    }
                } else if let selectedType {
                    RunTypeButton(
                        backgroundImageName: "buttonrun",
                        sfSymbolName: selectedType == .indoor ? "figure.run.treadmill" : "figure.run",
                        title: selectedType == .indoor ? "Indoor" : "Outdoor",
                        isSelected: true
                    ) {
                        step = .selectType
                    }
                    
                    zoneSelectionSection
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    
    private func selectType(_ type: RunType) {
        selectedType = type
        withAnimation(.easeInOut(duration: 0.25)) {
            step = .configureZone
        }
    }
    
    
    private var zoneSelectionSection: some View {
        VStack(spacing: 10) {
            Text("Choose your zone :")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, -50)
            
            Picker("Zone", selection: $selectedZone) {
                ForEach(1...5, id: \.self) { zone in
                    Text("\(zone)")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .tag(zone)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 250, height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            
            VStack(spacing: 20) {
                Button {
                    withAnimation {
                        step = .selectType
                        selectedType = nil
                    }
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color(red: 0.35, green: 0.12, blue: 0.05)))
                }
                
                Button {
                    if let selectedType {
                        onStartRun(selectedType, selectedZone)
                    }
                } label: {
                    Text("Start Run")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.orange))
                        .padding(.bottom, 20)
                }
            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    RunView(onStartRun: { type, zone in
        print("Start run: \(type), zone: \(zone)")
    })
}
