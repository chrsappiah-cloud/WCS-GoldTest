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

    // MARK: - Access & administration

    let accessRepository: LocalAccessPolicyRepository
    let authSession: AuthSessionService
    let accessControl: AccessControlService
    let administration: AdministrationService

    // MARK: - Data

    let scanRepository: ScanRepository
    let deviceRepository: DeviceRepository
    let reportRepository: ReportRepository
    let profileRepository: ProfileRepository
    let subscriptionService: SubscriptionService
    let testFlight: TestFlightService

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

        self.modelContainer = Self.makeModelContainer(inMemory: UITestLaunch.useInMemoryStore)
        let context = modelContainer.mainContext
        self.scanRepository = LocalScanRepository(modelContext: context)
        self.deviceRepository = LocalDeviceRepository()
        self.reportRepository = LocalReportRepository()
        self.profileRepository = LocalProfileRepository()

        self.accessRepository = LocalAccessPolicyRepository(modelContext: context)
        try? accessRepository.seedIfNeeded()

        self.authSession = AuthSessionService(repository: accessRepository)
        self.accessControl = AccessControlService(auth: authSession, repository: accessRepository)
        self.administration = AdministrationService(
            repository: accessRepository,
            accessControl: accessControl,
            auth: authSession
        )
        self.subscriptionService = SubscriptionService()
        self.subscriptionService.bind(accessControl: accessControl)
        self.testFlight = TestFlightService()
        self.testFlight.refresh()
    }

    func bootstrap() async {
        await accessControl.reloadPolicies()
        await authSession.restoreSession()
        await administration.refresh()
        subscriptionService.syncFromAccess()
        await prepareDeviceForTesting()
    }

    /// Auto-pair simulator probe and activate firmware for mock builds.
    func prepareDeviceForTesting() async {
        guard configuration.useMockBLE else {
            bleDeviceManager.startScan()
            return
        }
        bleDeviceManager.startScan()
        let probeID = MockDeviceTransport.simulatorProbeID
        if !bleDeviceManager.isConnected {
            try? await bleDeviceManager.connect(to: probeID)
        }
        await bleDeviceManager.activateFirmware()
    }

    func makeGoldScanViewModel() -> GoldScanViewModel {
        GoldScanViewModel(
            deviceManager: bleDeviceManager,
            mockTransport: mockDeviceTransport,
            rulesEngine: goldRulesEngine,
            fusionEngine: accuracyFusionEngine,
            motionService: motionStabilityService,
            repository: scanRepository,
            accessControl: accessControl,
            subscriptionService: subscriptionService
        )
    }

    private static func makeModelContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            PersistedScanSession.self,
            PersistedVaultItem.self,
            PersistedUserAccount.self,
            PersistedEntitlementPolicy.self,
        ])
        let config = ModelConfiguration(
            inMemory ? "UITestStore" : "AppStore",
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
