import SwiftUI

struct CalorieDetailView: View {
    var viewModel: CalorieViewModel
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            CloseButtonHeader(title: "Calorie Details",
                onClose: onClose)
            

            Text("TOTAL BURNING CALORIE OF THE DAY")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .tracking(0.5)
                .padding(.top, 24)
                
            ZStack {
                Circle()
                    .stroke(Color(hex: "E4783C"), lineWidth: 2)
                    .frame(width: 210, height: 210)
                    .padding(.top, 20)

                VStack(spacing: 0) {
                    Text("\(viewModel.totalCalories)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    Text("kcal")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)




            AnimatedFlameView(frames: ["flame1", "flame2", "flame3", "flame4", "flame5"])
                .frame(width: 210, height: 210)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
//                .padding(.bottom, 20)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
                .frame(width: 110, height: 110)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FFD65C"), Color(hex: "FF7A1E"), Color(hex: "E4483C")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
        }
        .padding(.top,-110)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct CalorieBreakdownCard: View {
    let title: String
    let kcal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "5AC8D8"))
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(kcal)")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text("Kcal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }
}

struct CloseButtonHeader: View {
    let title: String
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.secondaryNormal))
            }
            .buttonStyle(.plain)

            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
    }
}

#Preview {
    CalorieDetailView(
        viewModel: CalorieViewModel(healthManager: HealthKitManager()),
        onClose: {}
    )
}
