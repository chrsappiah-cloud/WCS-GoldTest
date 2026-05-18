import Foundation

enum AppEnvironment: String {
    case debug
    case staging
    case release
}

struct AppConfiguration {
    let environment: AppEnvironment
    let appStoreConnectAppID: String
    let supabaseURL: URL?
    let supabaseAnonKey: String?
    let metalsAPIKey: String?
    let useMockBLE: Bool

    /// Detect TestFlight / sandbox installs for channel-based entitlements.
    static var detectedChannel: DistributionChannel {
        #if DEBUG
        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
            return .internalQA
        }
        #endif
        if TestFlightDetector.isTestFlightInstall() {
            return .testFlight
        }
        return .appStore
    }

    nonisolated static var current: AppConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    /// Mock BLE in Simulator; real CoreBluetooth on physical devices. Override with launch args.
    nonisolated static var prefersMockBLE: Bool {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-realBLE") { return false }
        if args.contains("-mockBLE") { return true }
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    nonisolated static let debug = AppConfiguration(
        environment: .debug,
        appStoreConnectAppID: AppStoreConnect.appID,
        supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""),
        supabaseAnonKey: ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
        metalsAPIKey: ProcessInfo.processInfo.environment["METALS_API_KEY"],
        useMockBLE: prefersMockBLE
    )

    nonisolated static let release = AppConfiguration(
        environment: .release,
        appStoreConnectAppID: AppStoreConnect.appID,
        supabaseURL: nil,
        supabaseAnonKey: nil,
        metalsAPIKey: nil,
        useMockBLE: prefersMockBLE
    )
}
