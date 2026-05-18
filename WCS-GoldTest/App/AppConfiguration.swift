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
        if TestFlightService.detectTestFlightInstall() {
            return .testFlight
        }
        return .appStore
    }

    static var current: AppConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    static let debug = AppConfiguration(
        environment: .debug,
        appStoreConnectAppID: AppStoreConnect.appID,
        supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""),
        supabaseAnonKey: ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
        metalsAPIKey: ProcessInfo.processInfo.environment["METALS_API_KEY"],
        useMockBLE: true
    )

    static let release = AppConfiguration(
        environment: .release,
        appStoreConnectAppID: AppStoreConnect.appID,
        supabaseURL: nil,
        supabaseAnonKey: nil,
        metalsAPIKey: nil,
        useMockBLE: false
    )
}
