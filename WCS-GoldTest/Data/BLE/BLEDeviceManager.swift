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
    @Published private(set) var bluetoothState: CBManagerState = .unknown

    var isConnected: Bool { connectedPeripheralID != nil }

    private let central: CBCentralManager
    private var peripherals: [UUID: CBPeripheral] = [:]
    private let transport: (any DeviceTransporting)?

    override init() {
        self.central = CBCentralManager(delegate: nil, queue: .main)
        self.transport = nil
        super.init()
        self.central.delegate = self
    }

    init(transport: any DeviceTransporting) {
        self.central = CBCentralManager(delegate: nil, queue: .main)
        self.transport = transport
        super.init()
    }

    func startScan() {
        guard central.state == .poweredOn else { return }
        let service = CBUUID(string: BLEConstants.serviceUUID)
        central.scanForPeripherals(withServices: [service], options: nil)
    }

    func connect(to peripheralID: UUID) async throws {
        if let transport {
            try await transport.connect(to: peripheralID)
            connectedPeripheralID = peripheralID
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
        // Characteristic write integration — phase 1 hardware pilot
    }

    func disconnect() {
        if let transport {
            transport.disconnect()
        }
        if let id = connectedPeripheralID, let peripheral = peripherals[id] {
            central.cancelPeripheralConnection(peripheral)
        }
        connectedPeripheralID = nil
        measurementStream = []
    }

    func appendMeasurement(_ value: Double) {
        measurementStream.append(value)
    }
}

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
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        Task { @MainActor in
            if connectedPeripheralID == peripheral.identifier {
                connectedPeripheralID = nil
            }
        }
    }
}
