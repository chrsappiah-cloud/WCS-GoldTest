import SwiftUI
import UIKit

struct AppRouter: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(onComplete: { hasCompletedOnboarding = true })
            }
        }
        .tint(WCSTheme.goldMid)
        .preferredColorScheme(.dark)
        .task {
            await dependencies.bootstrap()
        }
    }
}

