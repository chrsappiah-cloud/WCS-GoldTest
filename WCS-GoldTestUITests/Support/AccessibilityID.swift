import Foundation

/// Mirror of app accessibility identifiers for UI tests.
enum AccessibilityID {
    enum Tab {
        static let home = "tab.home"
        static let scan = "tab.scan"
        static let vault = "tab.vault"
        static let reports = "tab.reports"
        static let settings = "tab.settings"
    }

    enum Onboarding {
        static let skip = "onboarding.skip"
        static let continueButton = "onboarding.continue"
        static let getStarted = "onboarding.getStarted"
    }

    enum Home {
        static let newGoldScan = "home.newGoldScan"
        static let pairDevice = "home.pairDevice"
        static let viewReports = "home.viewReports"
    }

    enum Firmware {
        static let activate = "firmware.activate"
    }

    enum Scan {
        static let checklistToggle = "scan.checklistToggle"
        static let startGoldScan = "scan.startGoldScan"
    }

    enum Settings {
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
        static let signIn = "auth.signIn"
        static let signUp = "auth.signUp"
        static let signOut = "auth.signOut"
    }

    enum Admin {
        static let users = "admin.users"
        static let entitlements = "admin.entitlements"
        static let testFlight = "admin.testFlight"
    }
}
