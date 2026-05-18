import Combine
import Foundation
import SwiftData

@MainActor
final class AppDependencies: ObservableObject {
    let configuration: AppConfiguration

    // MARK: - Device & measurement

    let deviceTransport: any DeviceTransporting
    let mockDeviceTransport: MockDeviceTransport?
    let bleDeviceManager: BLEDeviceManager

    // MARK: - Domain

    let goldRulesEngine: GoldRulesEngine
    let accuracyFusionEngine: AccuracyFusionEngine
    let motionStabilityService: MotionStabilityService

    // MARK: - Data

    let scanRepository: ScanRepository
    let deviceRepository: DeviceRepository
    let reportRepository: ReportRepository
    let profileRepository: ProfileRepository
    let subscriptionService: SubscriptionService

    // MARK: - Persistence

    let modelContainer: ModelContainer

    init(configuration: AppConfiguration = .current) {
        self.configuration = configuration

        let useMockBLE = configuration.useMockBLE
        if useMockBLE {
            let mock = MockDeviceTransport()
            self.mockDeviceTransport = mock
            self.deviceTransport = mock
            self.bleDeviceManager = BLEDeviceManager(transport: mock)
        } else {
            self.mockDeviceTransport = nil
            let manager = BLEDeviceManager()
            self.bleDeviceManager = manager
            self.deviceTransport = manager
        }

        self.goldRulesEngine = GoldRulesEngine()
        self.accuracyFusionEngine = AccuracyFusionEngine()
        self.motionStabilityService = MotionStabilityService()

        self.modelContainer = Self.makeModelContainer()
        let context = modelContainer.mainContext
        self.scanRepository = LocalScanRepository(modelContext: context)
        self.deviceRepository = LocalDeviceRepository()
        self.reportRepository = LocalReportRepository()
        self.profileRepository = LocalProfileRepository()
        self.subscriptionService = SubscriptionService()
    }

    func makeGoldScanViewModel() -> GoldScanViewModel {
        GoldScanViewModel(
            deviceManager: bleDeviceManager,
            mockTransport: mockDeviceTransport,
            rulesEngine: goldRulesEngine,
            fusionEngine: accuracyFusionEngine,
            motionService: motionStabilityService,
            repository: scanRepository
        )
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            PersistedScanSession.self,
            PersistedVaultItem.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
