//
//  RunTypeButton.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//

import SwiftUI

struct RunTypeButton: View {
    let backgroundImageName: String
    let sfSymbolName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack() {
                ZStack {
                    Image(backgroundImageName)
                        .resizable()
//                        .scaledToFill()
                        .frame(width: 250, height: 250)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16)
//                                .stroke(Color.orange.opacity(isSelected ? 0.8 : 0.3), lineWidth: 1.5)
//                        )
//                        .shadow(color: .orange.opacity(isSelected ? 0.5 : 0), radius: 20)
                    VStack{
                        Image(systemName: sfSymbolName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.orange)
                       
                        Text(title)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .offset(y: 10)
                        
                    }
                    
                
                }
//                .padding(.bottom, 20)
                
            }
        }
    }
}
