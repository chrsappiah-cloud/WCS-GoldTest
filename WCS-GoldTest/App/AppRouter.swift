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

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(WCSTheme.charcoal)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(WCSTheme.goldMid)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(WCSTheme.goldMid),
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.55, alpha: 1)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.55, alpha: 1),
        ]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            ScanTabView()
                .tabItem { Label("Scan", systemImage: "dot.radiowaves.left.and.right") }

            VaultView()
                .tabItem { Label("Vault", systemImage: "tray.full") }

            ReportsView()
                .tabItem { Label("Reports", systemImage: "doc.richtext") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
