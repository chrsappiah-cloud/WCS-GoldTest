import SwiftUI

struct FirmwareView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var activationMessage: String?

    private var manager: BLEDeviceManager { dependencies.bleDeviceManager }

    var body: some View {
        List {
            Section("Status") {
                LabeledContent("Activation", value: manager.firmwareActivationState.displayName)
                LabeledContent("Version", value: manager.firmwareVersion)
                LabeledContent("Build", value: manager.firmwareBuild)
                LabeledContent("Transport", value: manager.usesMockTransport ? "Simulator probe" : "Bluetooth LE")
                LabeledContent("Connection", value: manager.isConnected ? "Connected" : "Not connected")
            }

            Section {
                Button {
                    Task { await activate() }
                } label: {
                    Label(
                        manager.isFirmwareActive ? "Re-activate firmware" : "Activate firmware",
                        systemImage: "cpu"
                    )
                }
                .accessibilityIdentifier(AccessibilityID.Firmware.activate)
                .disabled(!manager.isConnected || manager.firmwareActivationState == .activating)

                if !manager.isConnected {
                    NavigationLink {
                        PairingView()
                    } label: {
                        Label("Pair device first", systemImage: "link")
                    }
                    .accessibilityIdentifier(AccessibilityID.Firmware.pairFirst)
                }
            } footer: {
                Text("Firmware must be active before gold scans. On Simulator, the mock WCS probe activates automatically.")
            }

            if let activationMessage {
                Section {
                    Text(activationMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Firmware")
        .accessibilityIdentifier(AccessibilityID.Firmware.screen)
    }

    private func activate() async {
        activationMessage = nil
        await manager.activateFirmware()
        activationMessage = manager.isFirmwareActive
            ? "Firmware \(manager.firmwareVersion) (build \(manager.firmwareBuild)) is active."
            : "Activation failed. Pair your probe and try again."
    }
}
