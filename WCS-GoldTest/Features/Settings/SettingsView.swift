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

                Section("TestFlight") {
                    NavigationLink {
                        TestFlightStatusView()
                    } label: {
                        Label("Beta build status", systemImage: "airplane")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.testFlightStatus)

                    if dependencies.testFlight.isTestFlightBuild {
                        Label("Running TestFlight beta", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }

                    Link("Open TestFlight in App Store Connect", destination: dependencies.testFlight.appStoreConnectTestFlightURL)
                }

                Section("App Store Connect") {
                    LabeledContent("App ID", value: AppStoreConnect.appID)
                    LabeledContent("Channel", value: AppConfiguration.detectedChannel.displayName)
                    LabeledContent("Build", value: "\(dependencies.testFlight.marketingVersion) (\(dependencies.testFlight.buildNumber))")
                    Link("Open in-flight version", destination: URL(string: "https://appstoreconnect.apple.com/apps/\(AppStoreConnect.appID)/distribution/ios/version/inflight")!)
                }

                Section("Device") {
                    NavigationLink {
                        FirmwareView()
                    } label: {
                        Label("Firmware", systemImage: "cpu")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.firmware)
                    NavigationLink {
                        CalibrationProfilesPlaceholderView()
                    } label: {
                        Label("Calibration profiles", systemImage: "slider.horizontal.3")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.calibration)
                    NavigationLink {
                        PairingView()
                    } label: {
                        Label("Pair probe", systemImage: "link")
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.pairProbe)
                }

                Section("Preferences") {
                    NavigationLink {
                        UnitsRegionView()
                    } label: {
                        Label("Units & region", systemImage: "ruler")
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
