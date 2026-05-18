import Foundation

struct PairedDevice: Identifiable, Hashable, Sendable {
    let id: UUID
    let serialNumber: String
    let model: String
    let firmwareVersion: String?
    let lastSeenAt: Date?
}

protocol DeviceRepository: Sendable {
    func fetchPairedDevices() async throws -> [PairedDevice]
    func register(serialNumber: String, activationCode: String) async throws -> PairedDevice
}

final class LocalDeviceRepository: DeviceRepository {
    func fetchPairedDevices() async throws -> [PairedDevice] { [] }

    func register(serialNumber: String, activationCode: String) async throws -> PairedDevice {
        PairedDevice(
            id: UUID(),
            serialNumber: serialNumber,
            model: "WCS Probe v1",
            firmwareVersion: "0.0.0-mock",
            lastSeenAt: .now
        )
    }
}
