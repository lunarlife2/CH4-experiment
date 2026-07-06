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
    let running: RunningType
    @State var selectedTab = 0
    
    var body: some View {
        NavigationStack{
            TabView(selection: $selectedTab) {
                ForEach(RunningType.running.indices, id: \.self) { index in
                    let item = RunningType.running[index]
                    
                    NavigationLink {
                        ZonePickerView(running: item)
                    } label: {
                        ZStack{
                            Circle().fill(Color.red)
                            VStack{
                                Image(systemName: item.icon)
                                    .resizable()
                                    .frame(width: 66, height: 76)
                                Text(item.name)
                            }
                            
                        }
                    }
                    .buttonStyle(.plain)
                    .tag(index)
                }
            }
            
            .tabViewStyle(.page)
        }
        
    }
}

#Preview {
    TabPagingView(running: RunningType(name: "Outdoor Run", icon: "figure.run", activity: .running, location: .outdoor))
    
}
