//
//  EndRunningView.swift
//  watch Watch App
//
//  Created by Yimei Winata on 07/07/26.
//

import SwiftUI

struct EndRunningView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack (alignment: .center) {
            Image(systemName: "figure.run")
            
            Text("Well Done!")
                .bold()
                .font(.system(size: 20))
            
            Text("You maintain in Zone 3 for 31 minutes!")
                .font(.system(size: 12))
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
}
