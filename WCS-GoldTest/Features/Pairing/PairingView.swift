import SwiftUI

struct PairingView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var isScanning = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                if isScanning {
                    ProgressView("Searching for probes…")
                }
                ForEach(dependencies.bleDeviceManager.discoveredPeripheralIDs, id: \.self) { id in
                    Button {
                        Task { await connect(id) }
                    } label: {
                        Label(id.uuidString.prefix(8) + "…", systemImage: "sensor.tag.radiowaves.forward")
                    }
                }
            } header: {
                Text("Nearby devices")
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
        .onAppear {
            isScanning = true
            dependencies.bleDeviceManager.startScan()
        }
    }

    private func connect(_ id: UUID) async {
        do {
            try await dependencies.bleDeviceManager.connect(to: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
