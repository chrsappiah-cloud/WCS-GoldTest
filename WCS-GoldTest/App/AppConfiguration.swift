import Foundation

enum AppEnvironment: String {
    case debug
    case staging
    case release
}

struct AppConfiguration {
    let environment: AppEnvironment
    let supabaseURL: URL?
    let supabaseAnonKey: String?
    let metalsAPIKey: String?
    let useMockBLE: Bool

    static var current: AppConfiguration {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    static let debug = AppConfiguration(
        environment: .debug,
        supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""),
        supabaseAnonKey: ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
        metalsAPIKey: ProcessInfo.processInfo.environment["METALS_API_KEY"],
        useMockBLE: true
    )

    static let release = AppConfiguration(
        environment: .release,
        supabaseURL: nil,
        supabaseAnonKey: nil,
        metalsAPIKey: nil,
        useMockBLE: false
    )
}
