import Foundation

protocol DeviceTransporting: AnyObject {
    var isConnected: Bool { get }
    func startScan()
    func connect(to peripheralID: UUID) async throws
    func send(_ command: DeviceCommand) async throws
    func disconnect()
}

enum DeviceCommand: Equatable, Sendable {
    case beginCalibration
    case startMeasurement(material: MaterialType)
    case stopMeasurement
    case requestBattery
    case requestFirmwareVersion
}

enum BLEServiceError: LocalizedError {
    case bluetoothUnavailable
    case peripheralNotFound
    case notConnected
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable: "Bluetooth is unavailable."
        case .peripheralNotFound: "Device not found."
        case .notConnected: "No device connected."
        case .writeFailed: "Failed to send command to device."
        }
    }
}

enum BLEConstants {
    static let serviceUUID = "8D2F1000-4F6B-4A6E-9AC0-4B3A11AA1000"
    static let commandUUID = "8D2F1001-4F6B-4A6E-9AC0-4B3A11AA1000"
    static let streamUUID = "8D2F1002-4F6B-4A6E-9AC0-4B3A11AA1000"
    static let batteryUUID = "8D2F1003-4F6B-4A6E-9AC0-4B3A11AA1000"
    static let configUUID = "8D2F1004-4F6B-4A6E-9AC0-4B3A11AA1000"
    static let firmwareUUID = "8D2F1005-4F6B-4A6E-9AC0-4B3A11AA1000"
    static let minimumBatteryPercent = 15
}
