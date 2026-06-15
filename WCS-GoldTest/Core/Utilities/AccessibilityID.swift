import Foundation

/// Centralized accessibility identifiers for UI automation.
enum AccessibilityID {
    enum Tab {
        static let home = "tab.home"
        static let scan = "tab.scan"
        static let vault = "tab.vault"
        static let reports = "tab.reports"
        static let settings = "tab.settings"
    }

    enum Onboarding {
        static let container = "onboarding.container"
        static let skip = "onboarding.skip"
        static let continueButton = "onboarding.continue"
        static let getStarted = "onboarding.getStarted"
    }

    enum Home {
        static let screen = "home.screen"
        static let newGoldScan = "home.newGoldScan"
        static let pairDevice = "home.pairDevice"
        static let viewReports = "home.viewReports"
    }

    enum Pairing {
        static let screen = "pairing.screen"
        static func deviceRow(_ id: UUID) -> String { "pairing.device.\(id.uuidString)" }
    }

    enum Firmware {
        static let screen = "firmware.screen"
        static let activate = "firmware.activate"
        static let pairFirst = "firmware.pairFirst"
    }

    enum Scan {
        static let screen = "scan.screen"
        static let checklistToggle = "scan.checklistToggle"
        static let surfaceDryToggle = "scan.surfaceDryToggle"
        static let stableHandToggle = "scan.stableHandToggle"
        static let startGoldScan = "scan.startGoldScan"
        static let materialPicker = "scan.materialPicker"
    }

    enum Vault {
        static let screen = "vault.screen"
        static let search = "vault.search"
    }

    enum Reports {
        static let screen = "reports.screen"
    }

    enum Settings {
        static let screen = "settings.screen"
        static let accountAccess = "settings.accountAccess"
        static let adminPanel = "settings.adminPanel"
        static let restorePurchases = "settings.restorePurchases"
        static let upgradeSubscription = "settings.upgradeSubscription"
        static let testFlightStatus = "settings.testFlightStatus"
        static let firmware = "settings.firmware"
        static let calibration = "settings.calibration"
        static let pairProbe = "settings.pairProbe"
    }

    enum Auth {
        static let email = "auth.email"
        static let password = "auth.password"
        static let displayName = "auth.displayName"
        static let signIn = "auth.signIn"
        static let signUp = "auth.signUp"
        static let signOut = "auth.signOut"
    }

    enum Admin {
        static let dashboard = "admin.dashboard"
        static let users = "admin.users"
        static let entitlements = "admin.entitlements"
        static let testFlight = "admin.testFlight"
    }
}

enum UITestLaunch {
    static let argument = "-ui-testing"
    static let skipOnboarding = "-skipOnboarding"
    static let inMemoryStore = "-inMemoryStore"

    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains(argument)
    }

    static func configureForTesting() {
        guard isActive else { return }
        if ProcessInfo.processInfo.arguments.contains(skipOnboarding) {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }

    static var useInMemoryStore: Bool {
        isActive && ProcessInfo.processInfo.arguments.contains(inMemoryStore)
    }
}
