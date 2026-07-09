import SwiftUI

struct ActivityCard: View {
    let icon: String
    let title: String
    let isTappable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: { if isTappable { action() } }) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(Color(hex: "C35A1D"))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
            .frame(height: 120)
            .background(
                ZStack {
                    Color(white: 0.12)
                    if isTappable {
                        Color(hex: "C35A1D").opacity(0.15)
                    }
                }
            )
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isTappable ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 16) {
            ActivityCard(icon: "flame", title: "Calorie", isTappable: true) {}
            ActivityCard(icon: "heart.fill", title: "Zone", isTappable: true) {}
        }
        .padding()
    }
}
