//
//  StatsCard.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 06/07/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let icon: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 25))
                    .foregroundColor(.orange)
                
                Text(value)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140, alignment: .leading)
        .background(Color(white: 0.12))
        .cornerRadius(20)
    }
}
