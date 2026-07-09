import SwiftUI
import WatchConnectivity
import Combine

struct HomeView: View {
    var healthManager: HealthKitManager
    var viewModel: ProfileViewModel
    @State private var connectivity = ConnectivityManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Activity Log")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    VStack {
                        Image("profile") //need to get the real data by view model on profile
                             .resizable()
                             .frame(width: 90, height: 90)
                             .clipShape(RoundedRectangle(cornerRadius: 15))
                             .padding(.top,40)

                        Text(viewModel.name)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "C35A1D"))
                    }
                    .padding(.horizontal, 2)
                }
                .padding(.vertical, 10)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 24),
                        GridItem(.flexible())
                    ],
                    spacing: 16
                ) {
                    ActivityCard(icon: "flame", title: "Calorie", isTappable: true) {
                        print("Calorie tapped")
                    }
                    ActivityCard(icon: "heart.fill", title: "Zone", isTappable: true) {
                        print("Zone tapped")
                    }
                    StatCard(title: "Total Time", icon: "alarm.fill", value: healthManager.totalTimeFormatted)
                    StatCard(title: "Total Distance", icon: "shoeprints.fill", value: String(format: "%.1f km", healthManager.totalDistanceKm))
                    StatCard(title: "BPM Average", icon: "waveform.path.ecg", value: "\(Int(healthManager.avgHeartRate))")
                    StatCard(title: "Pace Average", icon: "timer", value: healthManager.avgPaceFormatted)
                }

                WatchConnectedBadge(isConnected: connectivity.isPaired)
            }
            .padding(.horizontal, 20)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    HomeView(
        healthManager: HealthKitManager(),
        viewModel: ProfileViewModel(
            name: "Xera Kenedy",
            email: "xeraKen.edit@icoud.com",
            healthManager: HealthKitManager()
            )
    )
}
