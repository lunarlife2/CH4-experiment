import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            viewModel.model.backgroundGradient
                .ignoresSafeArea()
            Image(systemName: "shoeprints.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.2))
                .rotationEffect(.degrees(-15))
                .offset(x: -110, y: -320)

            Image(systemName: "shoeprints.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.2))
                .rotationEffect(.degrees(15))
                .offset(x: 110, y: -230)

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    HStack(spacing: 70) {
                        LeftHeartbeat()
                            .stroke(
                                Color.green,
                                style: StrokeStyle(
                                    lineWidth: 8,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .frame(width: 180, height: 80)

                        RightHeartbeat()
                            .stroke(
                                Color.orange.opacity(0.9),
                                style: StrokeStyle(
                                    lineWidth: 8,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .frame(width: 180, height: 80)
                    }

                    Image(systemName: "figure.run")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                        .foregroundStyle( LinearGradient( colors: [.green, .orange], startPoint: .leading, endPoint: .trailing ) )
                        .offset(y: -29)
                }
                .padding(.bottom, -10)

                VStack(spacing: 20) {
                    Text(viewModel.model.title)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.mint, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text(viewModel.model.subtitle)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        viewModel.continueTapped()
                    }) {
                        Text("Continue")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 225, height: 25)
                            .padding(.vertical, 16)
                            .background(Color(hex: "DF8E2A"))
                            .clipShape(Capsule())
                            .padding(.horizontal, 24)
                    }

                    HStack(spacing: 6) {
                        ForEach(1...viewModel.model.totalPages, id: \.self) { page in
                            Circle()
                                .fill(viewModel.dotColor(for: page))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
                .frame(maxWidth: .infinity)
                .background {
                    Ellipse()
                        .fill(
                            Color.white.opacity(0.08)
                        )
                        .frame(width: 450, height: 650)
                        .blur(radius: 2)
                        .offset(y: 150)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
