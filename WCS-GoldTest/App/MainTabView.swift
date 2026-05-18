import SwiftUI
import UIKit

enum AppTab: Int, CaseIterable {
    case home, scan, vault, reports, settings

    var title: String {
        switch self {
        case .home: "Home"
        case .scan: "Scan"
        case .vault: "Vault"
        case .reports: "Reports"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .scan: "dot.radiowaves.left.and.right"
        case .vault: "tray.full"
        case .reports: "doc.richtext"
        case .settings: "gearshape"
        }
    }

    var accessibilityID: String {
        switch self {
        case .home: AccessibilityID.Tab.home
        case .scan: AccessibilityID.Tab.scan
        case .vault: AccessibilityID.Tab.vault
        case .reports: AccessibilityID.Tab.reports
        case .settings: AccessibilityID.Tab.settings
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

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
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .accessibilityIdentifier(AccessibilityID.Tab.home)
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.icon) }
                .tag(AppTab.home)

            ScanTabView()
                .accessibilityIdentifier(AccessibilityID.Tab.scan)
                .tabItem { Label(AppTab.scan.title, systemImage: AppTab.scan.icon) }
                .tag(AppTab.scan)

            VaultView()
                .accessibilityIdentifier(AccessibilityID.Tab.vault)
                .tabItem { Label(AppTab.vault.title, systemImage: AppTab.vault.icon) }
                .tag(AppTab.vault)

            ReportsView()
                .accessibilityIdentifier(AccessibilityID.Tab.reports)
                .tabItem { Label(AppTab.reports.title, systemImage: AppTab.reports.icon) }
                .tag(AppTab.reports)

            SettingsView()
                .accessibilityIdentifier(AccessibilityID.Tab.settings)
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.icon) }
                .tag(AppTab.settings)
        }
        .accessibilityElement(children: .contain)
    }
}
