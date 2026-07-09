//
//  ProfileView.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 07/07/26.
//

import SwiftUI
struct ProfileView: View {

    @State private var viewModel: ProfileViewModel
//    @State private var localization = LocalizationManager.shared

    init(viewModel: ProfileViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.primaryDarker, Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
//                header
                avatarSection
//                languageSwitcher
                healthInfoList
                syncedBadge
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.onAppear()
        }
    }

//    private var header: some View {
//        HStack {
//            Button(action: {}) {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.white)
//                    .padding(20)
//                    .background(Circle().fill(Color.white.opacity(0.08)))
//            }
//            Spacer()
//        }
//    }

    private var avatarSection: some View {
        VStack(spacing: 8) {
            Image("profile")
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.orange, lineWidth: 2))
                .shadow(color: .orange.opacity(0.5), radius: 20)

            Text(viewModel.name)
                .font(.title2.bold())
                .foregroundColor(.white)

            Text(viewModel.email)
                .font(.subheadline)
                .foregroundColor(.orange)
        }
    }

//    private var languageSwitcher: some View {
//        HStack(spacing: 0) {
//            ForEach(AppLanguage.allCases, id: \.self) { lang in
//                Text(lang.displayName)
//                    .font(.subheadline.weight(.semibold))
//                    .foregroundColor(viewModel.selectedLanguage == lang ? .black : .white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 10)
//                    .background(
//                        Capsule()
//                            .fill(viewModel.selectedLanguage == lang ? Color.orange : Color.clear)
//                    )
//                    .onTapGesture {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            viewModel.selectLanguage(lang)
//                        }
//                    }
//            }
//        }
//        .padding(4)
//        .background(Capsule().fill(Color.white.opacity(0.08)))
//    }

    private var healthInfoList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Age")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(viewModel.ageText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("Year")
                        .font(.system(size: 18, weight:.semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 16)
            
            Divider().overlay(Color.orange.opacity(0.3))

            HStack {
                Text("Height")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(viewModel.heightText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("cm")
                        .font(.system(size: 18, weight:.semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 16)
            
            Divider().overlay(Color.orange.opacity(0.3))

            HStack {
                Text("Weight")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(viewModel.weightText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("kg")
                        .font(.system(size: 18, weight:.semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 16)
            
            Divider().overlay(Color.orange.opacity(0.3))
            
            HStack {
                Text("Max Heart Rate")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(viewModel.maxHeartRateText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("BPM")
                        .font(.system(size: 18, weight:.semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 16)
        }
    }


    private var syncedBadge: some View {
        Text(("Synced from Health App"))
            .font(.system(size: 16, weight:.semibold))
            .foregroundColor(.white.opacity(0.9))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.primaryDarker))
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(
            name: "Xera Kenedy",
            email: "xeraKen.edit@icoud.com",
            healthManager: HealthKitManager()
        )
    )
}
