import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            List {
                Section("Account & subscription") {
                    LabeledContent("Plan", value: dependencies.subscriptionService.tier.rawValue.capitalized)
                    Button("Restore purchases") {
                        Task { await dependencies.subscriptionService.refreshEntitlements() }
                    }
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
