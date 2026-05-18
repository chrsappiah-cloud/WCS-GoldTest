import CoreBluetooth
import SwiftUI

struct PairingView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var isScanning = false
    @State private var errorMessage: String?

    private var manager: BLEDeviceManager { dependencies.bleDeviceManager }

    var body: some View {
        List {
            Section("Bluetooth") {
                LabeledContent("State", value: bluetoothLabel)
                if manager.usesMockTransport {
                    Label("Simulator WCS probe enabled", systemImage: "iphone.gen3")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                if isScanning {
                    ProgressView("Searching for probes…")
                }
                ForEach(manager.discoveredPeripheralIDs, id: \.self) { id in
                    Button {
                        Task { await connect(id) }
                    } label: {
                        deviceLabel(for: id)
                    }
                    .accessibilityIdentifier(AccessibilityID.Pairing.deviceRow(id))
                }
                if manager.discoveredPeripheralIDs.isEmpty && !isScanning {
                    Text("No probes found. Power on your WCS probe or use the Simulator mock device.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Nearby devices")
            }

            if manager.isConnected {
                Section("Firmware") {
                    LabeledContent("Version", value: manager.firmwareVersion)
                    Button {
                        Task { await manager.activateFirmware() }
                    } label: {
                        Label("Activate firmware", systemImage: "cpu")
                    }
                    .accessibilityIdentifier(AccessibilityID.Firmware.activate)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Pair device")
        .accessibilityIdentifier(AccessibilityID.Pairing.screen)
        .onAppear {
            isScanning = true
            manager.startScan()
        }
    }

    private var bluetoothLabel: String {
        switch manager.bluetoothState {
        case .poweredOn: "Ready"
        case .poweredOff: "Off"
        case .unauthorized: "Permission required"
        case .unsupported: "Unsupported"
        default: "Unavailable"
        }
    }

    private func deviceLabel(for id: UUID) -> some View {
        let name: String = if id == MockDeviceTransport.simulatorProbeID {
            "WCS Probe (Simulator)"
        } else {
            String(id.uuidString.prefix(8)) + "…"
        }
        return Label(name, systemImage: "sensor.tag.radiowaves.forward")
    }

    private func connect(_ id: UUID) async {
        errorMessage = nil
        do {
            try await manager.connect(to: id)
            await manager.activateFirmware()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
