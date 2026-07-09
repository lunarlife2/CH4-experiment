//
//  EndRunningView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI

struct EndRunningView: View {
    @Environment(RunningSessionManager.self) private var sessionManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack (alignment: .center) {
            Image("logo-ranup-watch")
                .resizable()
                .frame(maxWidth: 91, maxHeight: 69)
            
            Text("Well Done!")
                .font(.system(size: 19, weight: .semibold))
            
            Text("You maintain in Zone 3 for 31 minutes!")
                .font(.system(size: 13, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }

            }
        }
    }
}

#Preview {
    EndRunningView()
        .environment(RunningSessionManager())
}
