//
//  TabPagingView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 05/07/26.
//

import SwiftUI
import WorkoutKit
import HealthKit

struct TabPagingView: View {
//    @Environment(RunningSessionManager.self) private var sessionManager
    @State private var sessionManager = RunningSessionManager.shared
    @State var selectedTab = 0
    
    var body: some View {
        NavigationStack{
            TabView(selection: $selectedTab) {
                ForEach(RunningType.running.enumerated(), id: \.element.id) { index, item in
                    
                    NavigationLink {
                        ZonePickerView()
                            .environment(sessionManager)
                    } label: {
                        ZStack{
                            Circle().fill(Color.accentDarkHover)
                            VStack{
                                Image(systemName: item.icon)
                                    .resizable()
                                    .frame(width: index == 0 ? 66 : 86, height: 76)
                                    .foregroundStyle(Color.secondaryNormal)
                                Text(item.name)
                                    .foregroundStyle(Color.secondaryNormal)
                            }
                            
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded({
                        sessionManager.runningType = item
                    }))
                    .buttonStyle(.plain)
                    .tag(index)
                }
            }
            
            .tabViewStyle(.page)
        }
        
    }
}

#Preview {
    TabPagingView()
        .environment(RunningSessionManager.shared)
}
