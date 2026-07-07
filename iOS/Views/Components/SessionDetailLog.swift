//
//  SessionDetailLog.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI

struct SessionDetailLog: View {
    let sessions: [RunSession]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SESSION DETAIL LOG")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(sessions) { session in
                HStack(spacing: 12) {
                    // Placeholder route icon.
                    // Route GPS needs HKWorkoutRoute + CLLocation
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(white: 0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "figure.run")
                                .foregroundColor(.orange)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dateFormatted(session.date))
                             Text("\(String(format: "%.1f", session.distanceKm)) KM | \(session.paceFormatted)")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                    Spacer()
                }

                if session.id != sessions.last?.id {
                    Divider().background(Color.gray.opacity(0.3))
                }
            }
        }
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
    }
}
