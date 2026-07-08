//
//  WatchConnectedBadge.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI

struct WatchConnectedBadge: View {
    var isConnected: Bool
    
    var body: some View {
        HStack( spacing: 6) {
            Text(isConnected ? "Watch Connected" : "Watch Not Connected")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)
                .fontWeight(.semibold)
            
            Image(systemName: "applewatch")
                .font(.system(size: 28))
                .foregroundColor(.orange)
                .overlay(
                    Image(systemName: isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(isConnected ? .green : .red)
                        .background(Color.black.clipShape(Circle()))
                        .offset(x: 8, y: -8)
                )
        }
        .frame(maxWidth: .infinity, alignment: .center)
       
////        .overlay(
//////            RoundedRectangle(cornerRadius: 8)
//////                .stroke(Color.orange, lineWidth: 1)
//        )
    }
}
