//
//  ActivityCard.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 06/07/26.
//

import SwiftUI

struct ActivityCard: View {
    let icon: String
    let title: String
    var isTappable: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.orange)
                .shadow(color: .orange.opacity(0.6), radius: 20)
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .semibold))
        }
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
        .background(
            ZStack {
                Color(white: 0.12)
                if isTappable {
                    Color(hex: "C35A1D").opacity(0.15)
                }
            }
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isTappable ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isTappable {
                action?()
                
            }
        }
    }
}
