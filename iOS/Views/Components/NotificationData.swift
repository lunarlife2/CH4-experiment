//
//  NotificationData.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//

import SwiftUI

struct NotifChipView: View {
    let type: RunSummaryViewModel.NotifType
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(type.message)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 19)
        .padding(.vertical,24)
        .background(type.tintColor)
        .glassEffect(.regular.tint(type.tintColor.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(type.tintColor.opacity(0.55), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}
#Preview("Saved") {
    ZStack {
        Color.black.ignoresSafeArea()
        NotifChipView(type: .saved, onClose: {})
        
    }
}

#Preview("Not saved") {
    ZStack {
        Color.black.ignoresSafeArea()
        NotifChipView(type: .notSaved, onClose: {})
    }
}
