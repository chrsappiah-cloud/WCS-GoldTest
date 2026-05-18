import Combine
import CoreBluetooth
import Foundation

@MainActor
final class BLEDeviceManager: NSObject, ObservableObject, DeviceTransporting {
    @Published private(set) var discoveredPeripheralIDs: [UUID] = []
    @Published private(set) var connectedPeripheralID: UUID?
    @Published private(set) var measurementStream: [Double] = []
    @Published private(set) var batteryLevel: Int = 100
    @Published private(set) var firmwareVersion: String = "—"
    @Published private(set) var firmwareBuild: String = "—"
    @Published private(set) var firmwareActivationState: FirmwareActivationState = .inactive
    @Published private(set) var bluetoothState: CBManagerState = .unknown
    @Published private(set) var usesMockTransport: Bool

    var isConnected: Bool { connectedPeripheralID != nil }
    var isFirmwareActive: Bool { firmwareActivationState == .active }

    private let central: CBCentralManager
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var characteristics: [CBUUID: CBCharacteristic] = [:]
    private let transport: (any DeviceTransporting)?
    private let mockTransport: MockDeviceTransport?

    override init() {
        self.central = CBCentralManager(delegate: nil, queue: .main)
        self.transport = nil
        self.mockTransport = nil
        self.usesMockTransport = false
        super.init()
        self.central.delegate = self
    }

    init(transport: MockDeviceTransport) {
        self.central = CBCentralManager(delegate: nil, queue: .main)
        self.transport = transport
        self.mockTransport = transport
        self.usesMockTransport = true
        super.init()
        transport.deviceManager = self
    }

    func startScan() {
        if let transport {
            transport.startScan()
            if usesMockTransport {
                let id = MockDeviceTransport.simulatorProbeID
                if !discoveredPeripheralIDs.contains(id) {
                    discoveredPeripheralIDs.append(id)
                }
            }
            return
        }
        guard central.state == .poweredOn else { return }
        let service = CBUUID(string: BLEConstants.serviceUUID)
        central.scanForPeripherals(withServices: [service], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func connect(to peripheralID: UUID) async throws {
        if let transport {
            try await transport.connect(to: peripheralID)
            return
        }
        guard let peripheral = peripherals[peripheralID] else {
            throw BLEServiceError.peripheralNotFound
        }
        central.connect(peripheral, options: nil)
    }

    func send(_ command: DeviceCommand) async throws {
        if let transport {
            try await transport.send(command)
            return
        }
        guard isConnected else { throw BLEServiceError.notConnected }
        guard let characteristic = characteristics[commandCharacteristicUUID] else {
            throw BLEServiceError.writeFailed
        }
        guard let peripheral = connectedPeripheral,
              let data = command.writePayload else {
            throw BLEServiceError.writeFailed
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    func disconnect() {
        if let transport {
            transport.disconnect()
            return
        }
        if let id = connectedPeripheralID, let peripheral = peripherals[id] {
            central.cancelPeripheralConnection(peripheral)
        }
        noteDisconnected()
    }

    func activateFirmware() async {
        guard isConnected else {
            firmwareActivationState = .failed
            return
        }
        firmwareActivationState = .activating
        do {
            try await send(.requestFirmwareVersion)
            if usesMockTransport {
                firmwareActivationState = .active
            }
        } catch {
            firmwareActivationState = .failed
        }
    }

    func appendMeasurement(_ value: Double) {
        measurementStream.append(value)
    }

    func noteConnected(peripheralID: UUID) {
        connectedPeripheralID = peripheralID
    }

    func noteDisconnected() {
        connectedPeripheralID = nil
        measurementStream = []
        characteristics = [:]
        if !usesMockTransport {
            firmwareActivationState = .inactive
            firmwareVersion = "—"
            firmwareBuild = "—"
        }
    }

    func applySimulatedProbeDefaults() {
        batteryLevel = 87
        applyFirmware(FirmwareInfo.simulatorDefault)
    }

    func applyFirmware(_ info: FirmwareInfo) {
        firmwareVersion = info.version
        firmwareBuild = info.build
        firmwareActivationState = .active
    }

    func updateBatteryLevel(_ level: Int) {
        batteryLevel = max(0, min(100, level))
    }

    private var connectedPeripheral: CBPeripheral? {
        guard let id = connectedPeripheralID else { return nil }
        return peripherals[id]
    }

    private var commandCharacteristicUUID: CBUUID {
        CBUUID(string: BLEConstants.commandUUID)
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEDeviceManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            bluetoothState = central.state
            guard central.state == .poweredOn else { return }
            startScan()
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        Task { @MainActor in
            peripherals[peripheral.identifier] = peripheral
            if !discoveredPeripheralIDs.contains(peripheral.identifier) {
                discoveredPeripheralIDs.append(peripheral.identifier)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            connectedPeripheralID = peripheral.identifier
            peripheral.delegate = self
            peripheral.discoverServices([CBUUID(string: BLEConstants.serviceUUID)])
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        Task { @MainActor in
            if connectedPeripheralID == peripheral.identifier {
                noteDisconnected()
            }
        }
    }
}

// MARK: - CBPeripheralDelegate

extension BLEDeviceManager: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task { @MainActor in
            guard error == nil else { return }
            let uuids = [
                BLEConstants.commandUUID,
                BLEConstants.streamUUID,
                BLEConstants.batteryUUID,
                BLEConstants.firmwareUUID,
            ].map { CBUUID(string: $0) }
            peripheral.services?
                .filter { $0.uuid == CBUUID(string: BLEConstants.serviceUUID) }
                .forEach { peripheral.discoverCharacteristics(uuids, for: $0) }
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        Task { @MainActor in
            guard error == nil else { return }
            service.characteristics?.forEach { characteristic in
                characteristics[characteristic.uuid] = characteristic
                switch characteristic.uuid.uuidString.uppercased() {
                case BLEConstants.batteryUUID.uppercased():
                    peripheral.readValue(for: characteristic)
                case BLEConstants.firmwareUUID.uppercased():
                    peripheral.readValue(for: characteristic)
                case BLEConstants.streamUUID.uppercased():
                    peripheral.setNotifyValue(true, for: characteristic)
                default:
                    break
                }
            }
            if characteristics[CBUUID(string: BLEConstants.firmwareUUID)] != nil {
                firmwareActivationState = .active
            }
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        Task { @MainActor in
            guard error == nil, let data = characteristic.value else { return }
            switch characteristic.uuid.uuidString.uppercased() {
            case BLEConstants.firmwareUUID.uppercased():
                let text = String(data: data, encoding: .utf8) ?? ""
                let parts = text.split(separator: "+", maxSplits: 1).map(String.init)
                firmwareVersion = parts.first ?? text
                firmwareBuild = parts.count > 1 ? parts[1] : "—"
                firmwareActivationState = .active
            case BLEConstants.batteryUUID.uppercased():
                if let byte = data.first {
                    updateBatteryLevel(Int(byte))
                }
            case BLEConstants.streamUUID.uppercased():
                if data.count >= MemoryLayout<Float>.size {
                    let value = data.withUnsafeBytes { $0.load(as: Float.self) }
                    appendMeasurement(Double(value))
                }
            default:
                break
            }
        }
    }
}

private extension DeviceCommand {
    var writePayload: Data? {
        switch self {
        case .beginCalibration:
            return Data([0x01])
        case .startMeasurement(let material):
            let code: UInt8 = switch material {
            case .gold: 0x10
            case .diamond: 0x11
            case .gemstone: 0x12
            }
            return Data([0x02, code])
        case .stopMeasurement:
            return Data([0x03])
        case .requestBattery:
            return Data([0x04])
        case .requestFirmwareVersion:
            return Data([0x05])
        }
    }
}
