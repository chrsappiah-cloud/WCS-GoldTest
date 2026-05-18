import Combine
import Foundation

/// Nonisolated TestFlight detection for use from AppConfiguration and services.
enum TestFlightDetector {
    static func isTestFlightInstall() -> Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.path.contains("sandboxReceipt")
    }

    static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}

/// TestFlight install detection and beta metadata for in-app UX.
@MainActor
final class TestFlightService: ObservableObject {
    @Published private(set) var isTestFlightBuild: Bool = false
    @Published private(set) var isAppStoreBuild: Bool = false
    @Published private(set) var buildNumber: String = "—"
    @Published private(set) var marketingVersion: String = "—"
    @Published private(set) var bundleIdentifier: String = ""

    var testFlightPublicLink: URL? {
        URL(string: "https://testflight.apple.com/join/\(TestFlightConfig.publicInviteCode)")
    }

    var appStoreConnectTestFlightURL: URL {
        URL(string: "https://appstoreconnect.apple.com/apps/\(AppStoreConnect.appID)/testflight")!
    }

    func refresh() {
        isTestFlightBuild = TestFlightDetector.isTestFlightInstall()
        isAppStoreBuild = !isTestFlightBuild && !TestFlightDetector.isDebugBuild
        buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    }

    /// Apply TestFlight channel defaults for newly registered users on beta builds.
    func suggestedChannelForNewUser() -> DistributionChannel {
        isTestFlightBuild ? .testFlight : AppConfiguration.detectedChannel
    }
}

enum TestFlightConfig {
    /// Replace with your public TestFlight invite code from App Store Connect → TestFlight → Public Link.
    static let publicInviteCode = "WCSGOLDTEST"
}
