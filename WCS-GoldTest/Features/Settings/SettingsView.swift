import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            List {
                Section("Account & access") {
                    NavigationLink {
                        UserAccessView()
                    } label: {
                        Label("Sign in & entitlements", systemImage: "person.crop.circle")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.accountAccess)
                    LabeledContent("Plan", value: dependencies.subscriptionService.tier == .premium ? "Premium" : "Free")
                    if dependencies.authSession.isAuthenticated,
                       let user = dependencies.authSession.currentUser {
                        LabeledContent("Signed in as", value: user.email)
                    }
                    NavigationLink {
                        SubscriptionPaywallView()
                    } label: {
                        Label("Upgrade subscription", systemImage: "star.fill")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.upgradeSubscription)
                    Button("Restore purchases") {
                        Task { await dependencies.subscriptionService.refreshEntitlements() }
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.restorePurchases)
                }

                if dependencies.administration.canOpenAdminPanel {
                    Section("Administration") {
                        NavigationLink {
                            AdminDashboardView()
                        } label: {
                            Label("Admin panel", systemImage: "shield.lefthalf.filled")
                        }
                        .accessibilityIdentifier(AccessibilityID.Settings.adminPanel)
                    }
                }

                Section("App Store Connect") {
                    LabeledContent("App ID", value: AppStoreConnect.appID)
                    LabeledContent("Channel", value: AppConfiguration.detectedChannel.displayName)
                    Link("Open in-flight version", destination: URL(string: "https://appstoreconnect.apple.com/apps/\(AppStoreConnect.appID)/distribution/ios/version/inflight")!)
                }

                Section("Device") {
                    NavigationLink("Firmware") {
                        Text("Firmware \(dependencies.bleDeviceManager.firmwareVersion)")
                            .navigationTitle("Firmware")
                    }
                    NavigationLink("Calibration profiles") {
                        CalibrationProfilesPlaceholderView()
                    }
                }

                Section("Preferences") {
                    NavigationLink("Units & region") {
                        Text("Coming in phase 2")
                            .navigationTitle("Units & region")
                    }
                }

                Section("Safety & legal") {
                    Text(LegalCopy.settingsSafety)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .wcsLuxuryScreen()
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .accessibilityIdentifier(AccessibilityID.Settings.screen)
        }
    }
}

struct CalibrationProfilesPlaceholderView: View {
    var body: some View {
        ContentUnavailableView(
            "No calibration profiles",
            systemImage: "slider.horizontal.3",
            description: Text("Profiles sync after device pairing and lab calibration.")
        )
        .navigationTitle("Calibration")
    }
}
