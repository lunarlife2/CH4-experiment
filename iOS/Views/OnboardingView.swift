import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()

	var body: some View {

			switch vm.step {

			case .welcome:
				WelcomeView(vm: vm)

			case .permissions:
				PermissionsView(vm: vm)

			case .profile:
				ProfileSetupView(vm: vm)

			case .finish:
				CompletionView()
			}
		}
}

#Preview {
    OnboardingView()
}
