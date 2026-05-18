import Combine
import Foundation

@MainActor
final class GoldScanViewModel: ObservableObject {
    @Published var state: ScanViewState = .idle
    @Published var selectedMaterial: MaterialType = .gold
    @Published var checklistComplete = false
    @Published var liveSignal: [Double] = []
    @Published var result: ScanResult?
    @Published var errorMessage: String?

    private let deviceManager: BLEDeviceManager
    private let rulesEngine: GoldRulesEngine
    private let fusionEngine: AccuracyFusionEngine
    private let motionService: MotionStabilityService
    private let repository: ScanRepository
    private let mockTransport: MockDeviceTransport?

    init(
        deviceManager: BLEDeviceManager,
        mockTransport: MockDeviceTransport? = nil,
        rulesEngine: GoldRulesEngine,
        fusionEngine: AccuracyFusionEngine,
        motionService: MotionStabilityService,
        repository: ScanRepository
    ) {
        self.deviceManager = deviceManager
        self.mockTransport = mockTransport
        self.rulesEngine = rulesEngine
        self.fusionEngine = fusionEngine
        self.motionService = motionService
        self.repository = repository
    }

    func beginChecklist() {
        state = .checklist
    }

    func startScan() async {
        guard checklistComplete else {
            errorMessage = "Complete the pre-scan checklist first."
            return
        }
        guard deviceManager.batteryLevel >= BLEConstants.minimumBatteryPercent else {
            errorMessage = "Battery too low for a safe scan."
            state = .failed
            return
        }

        state = .scanning
        liveSignal = []
        result = nil
        errorMessage = nil
        motionService.start()

        do {
            if !deviceManager.isConnected {
                try await deviceManager.connect(to: UUID())
            }

            try await deviceManager.send(.startMeasurement(material: selectedMaterial))
            mockTransport?.simulateMeasurementStream(into: deviceManager)

            for _ in 0..<60 {
                try await Task.sleep(for: .milliseconds(100))
                liveSignal = deviceManager.measurementStream
                if liveSignal.count >= 40 { break }
            }

            let base = rulesEngine.evaluate(signal: liveSignal)
            let fused = fusionEngine.fuse(
                basePurity: base.estimatedPurityPercent ?? 0,
                baseKarat: base.estimatedKarat ?? 0,
                evidence: EvidenceBundle(
                    probeSignalScore: base.confidence,
                    motionStabilityScore: motionService.stabilityScore,
                    calibrationFreshnessScore: 0.85,
                    imageSupportScore: 0.5,
                    repeatedScanAgreementScore: 0.7,
                    cloudConsensusScore: 0.5
                )
            )

            var warnings = base.warnings + fused.warnings
            if fused.confidence < 0.6 {
                warnings.append("Low confidence — consider recalibrating or rescanning")
            }

            result = ScanResult(
                estimatedPurityPercent: fused.estimatedPurityPercent,
                estimatedKarat: fused.estimatedKarat,
                classification: base.classification,
                confidence: fused.confidence,
                warnings: warnings,
                provenance: .bleOnly
            )

            let session = ScanSession(
                material: selectedMaterial,
                deviceId: deviceManager.connectedPeripheralID?.uuidString ?? "simulator",
                rawSignals: liveSignal,
                result: result
            )
            try await repository.save(session: session)
            state = .completed
        } catch {
            errorMessage = error.localizedDescription
            state = .failed
        }

        motionService.stop()
        try? await deviceManager.send(.stopMeasurement)
    }

    func reset() {
        state = .idle
        checklistComplete = false
        liveSignal = []
        result = nil
        errorMessage = nil
    }
}
