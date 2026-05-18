import Foundation

/// App Store Connect — WCS Gold Test (in-flight distribution).
enum AppStoreConnect {
    static let appID = "6770415355"
    static let bundleIdentifier = "wcs.WCS-GoldTest"
}

enum DistributionChannel: String, Codable, CaseIterable, Identifiable, Sendable {
    case appStore
    case testFlight
    case internalQA

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appStore: "App Store"
        case .testFlight: "TestFlight"
        case .internalQA: "Internal QA"
        }
    }
}

enum UserRole: String, Codable, CaseIterable, Identifiable, Sendable {
    case guest
    case registered
    case testFlightTester
    case subscriber
    case administrator

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .guest: "Guest"
        case .registered: "Registered"
        case .testFlightTester: "TestFlight Tester"
        case .subscriber: "Subscriber"
        case .administrator: "Administrator"
        }
    }

    var isAdmin: Bool { self == .administrator }
}

enum AppFeature: String, Codable, CaseIterable, Identifiable, Sendable {
    case goldScan
    case diamondScan
    case gemstoneScan
    case vaultUnlimited
    case pdfReports
    case cloudSync
    case deviceDiagnostics
    case firmwareUpdates
    case adminPanel
    case valuationAPI

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .goldScan: "Gold scan"
        case .diamondScan: "Diamond scan"
        case .gemstoneScan: "Gemstone scan"
        case .vaultUnlimited: "Unlimited vault"
        case .pdfReports: "PDF reports"
        case .cloudSync: "Cloud sync"
        case .deviceDiagnostics: "Device diagnostics"
        case .firmwareUpdates: "Firmware updates"
        case .adminPanel: "Administration panel"
        case .valuationAPI: "Market valuation API"
        }
    }

    var systemImage: String {
        switch self {
        case .goldScan: "circle.hexagongrid.fill"
        case .diamondScan: "diamond.fill"
        case .gemstoneScan: "sparkles"
        case .vaultUnlimited: "tray.full"
        case .pdfReports: "doc.richtext"
        case .cloudSync: "icloud"
        case .deviceDiagnostics: "waveform.path.ecg"
        case .firmwareUpdates: "arrow.down.circle"
        case .adminPanel: "shield.lefthalf.filled"
        case .valuationAPI: "chart.line.uptrend.xyaxis"
        }
    }
}

enum SubscriptionPlan: String, Codable, CaseIterable, Identifiable, Sendable {
    case free
    case testFlightBeta
    case premiumMonthly
    case premiumAnnual

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .testFlightBeta: "TestFlight Beta"
        case .premiumMonthly: "Premium Monthly"
        case .premiumAnnual: "Premium Annual"
        }
    }
}

struct FeatureEntitlementPolicy: Codable, Hashable, Sendable {
    let plan: SubscriptionPlan
    let channel: DistributionChannel
    let enabledFeatures: Set<AppFeature>
    let scanLimitPerPeriod: Int?
    let notes: String?

    static func defaultPolicies() -> [FeatureEntitlementPolicy] {
        [
            FeatureEntitlementPolicy(
                plan: .free,
                channel: .appStore,
                enabledFeatures: [.goldScan, .vaultUnlimited],
                scanLimitPerPeriod: 5,
                notes: "App Store free tier"
            ),
            FeatureEntitlementPolicy(
                plan: .testFlightBeta,
                channel: .testFlight,
                enabledFeatures: Set(AppFeature.allCases.filter { $0 != .adminPanel }),
                scanLimitPerPeriod: nil,
                notes: "Full feature access for beta validation — ASC \(AppStoreConnect.appID)"
            ),
            FeatureEntitlementPolicy(
                plan: .premiumMonthly,
                channel: .appStore,
                enabledFeatures: [
                    .goldScan, .diamondScan, .gemstoneScan, .vaultUnlimited,
                    .pdfReports, .cloudSync, .deviceDiagnostics, .valuationAPI,
                ],
                scanLimitPerPeriod: nil,
                notes: "Premium monthly"
            ),
            FeatureEntitlementPolicy(
                plan: .premiumAnnual,
                channel: .appStore,
                enabledFeatures: [
                    .goldScan, .diamondScan, .gemstoneScan, .vaultUnlimited,
                    .pdfReports, .cloudSync, .deviceDiagnostics, .firmwareUpdates, .valuationAPI,
                ],
                scanLimitPerPeriod: nil,
                notes: "Premium annual"
            ),
            FeatureEntitlementPolicy(
                plan: .free,
                channel: .testFlight,
                enabledFeatures: [.goldScan, .deviceDiagnostics],
                scanLimitPerPeriod: 10,
                notes: "Restricted TestFlight invite before admin approval"
            ),
        ]
    }
}

struct ManagedUserAccount: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var email: String
    var displayName: String
    var role: UserRole
    var plan: SubscriptionPlan
    var channel: DistributionChannel
    var isActive: Bool
    var testFlightApproved: Bool
    var featureOverrides: Set<AppFeature>
    var deniedFeatures: Set<AppFeature>
    var createdAt: Date
    var lastLoginAt: Date?

    init(
        id: UUID = UUID(),
        email: String,
        displayName: String,
        role: UserRole = .registered,
        plan: SubscriptionPlan = .free,
        channel: DistributionChannel = .appStore,
        isActive: Bool = true,
        testFlightApproved: Bool = false,
        featureOverrides: Set<AppFeature> = [],
        deniedFeatures: Set<AppFeature> = [],
        createdAt: Date = .now,
        lastLoginAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.plan = plan
        self.channel = channel
        self.isActive = isActive
        self.testFlightApproved = testFlightApproved
        self.featureOverrides = featureOverrides
        self.deniedFeatures = deniedFeatures
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
}

struct AccessDecision: Sendable {
    let allowed: Bool
    let feature: AppFeature
    let reason: String
}
