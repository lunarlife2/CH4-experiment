//
//  CustomTabBar.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI
 
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var onPlusTapped: () -> Void
 
    var body: some View {
        HStack() {

            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(6)
            .background(
                Capsule()
                    .fill(Color(red: 0.14, green: 0.24, blue: 0.22))
            )

        }
        .padding(.horizontal)
    }
 
    private func tabButton(for tab: Tab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: 18, weight: .semibold))
 
                if selectedTab == tab {
                    Text(tab.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(selectedTab == tab ? .orange : .black)
            .padding(.horizontal, selectedTab == tab ? 16 : 14)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(selectedTab == tab ? Color(hex: "285F5D") : Color.clear)
            )
        }
    }
}
