import Combine
import Foundation

@MainActor
final class MockDeviceTransport: DeviceTransporting {
    /// Stable ID shown in Pairing when running in the simulator.
    static let simulatorProbeID = UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!

    @Published private(set) var isConnected = false
    private var streamTask: Task<Void, Never>?
    weak var deviceManager: BLEDeviceManager?

    func startScan() {}

    func connect(to peripheralID: UUID) async throws {
        try await Task.sleep(for: .milliseconds(400))
        isConnected = true
        deviceManager?.noteConnected(peripheralID: peripheralID)
        deviceManager?.applySimulatedProbeDefaults()
    }

    func send(_ command: DeviceCommand) async throws {
        guard isConnected else { throw BLEServiceError.notConnected }
        guard let manager = deviceManager else { return }
        switch command {
        case .startMeasurement:
            break
        case .requestFirmwareVersion:
            manager.applyFirmware(FirmwareInfo.simulatorDefault)
        case .requestBattery:
            manager.updateBatteryLevel(87)
        case .stopMeasurement:
            streamTask?.cancel()
            streamTask = nil
        case .beginCalibration:
            break
        }
    }

    func disconnect() {
        streamTask?.cancel()
        streamTask = nil
        isConnected = false
        deviceManager?.noteDisconnected()
    }

    func simulateMeasurementStream(into manager: BLEDeviceManager) {
        streamTask?.cancel()
        streamTask = Task {
            for i in 0..<48 {
                guard !Task.isCancelled else { return }
                let t = Double(i) / 48.0
                let value = 0.25 + 0.22 * sin(t * .pi * 2) + Double.random(in: -0.02...0.02)
                manager.appendMeasurement(value)
                try? await Task.sleep(for: .milliseconds(120))
            }
        }
    }
}
