import Combine
import Foundation

@MainActor
final class MockDeviceTransport: DeviceTransporting {
    @Published private(set) var isConnected = false
    private var streamTask: Task<Void, Never>?

    func startScan() {}

    func connect(to peripheralID: UUID) async throws {
        try await Task.sleep(for: .milliseconds(400))
        isConnected = true
    }

    func send(_ command: DeviceCommand) async throws {
        guard isConnected else { throw BLEServiceError.notConnected }
        switch command {
        case .startMeasurement:
            break
        default:
            break
        }
    }

    func disconnect() {
        streamTask?.cancel()
        streamTask = nil
        isConnected = false
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
