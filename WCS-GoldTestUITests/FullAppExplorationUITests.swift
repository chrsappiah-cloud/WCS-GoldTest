import XCTest

/// Exercises primary tabs, navigation links, and firmware activation in mock/simulator mode.
final class FullAppExplorationUITests: WCSUITestCase {

    func testAllTabsAndPrimaryNavigationLinks() throws {
        selectTab("Home")
        assertNavigationTitle("Home")
        XCTAssertTrue(app.staticTexts["Device status"].exists)
        tapButton(identifier: AccessibilityID.Home.pairDevice, fallbackLabel: "Pair Device")
        assertNavigationTitle("Pair device")
        navigateBack()
        tapButton(identifier: AccessibilityID.Home.viewReports, fallbackLabel: "View Reports")
        assertNavigationTitle("Reports")
        navigateBack()

        selectTab("Scan")
        assertNavigationTitle("Scan")
        XCTAssertTrue(app.staticTexts["Material"].exists)

        selectTab("Vault")
        assertNavigationTitle("Vault")

        selectTab("Reports")
        assertNavigationTitle("Reports")

        selectTab("Settings")
        assertNavigationTitle("Settings")
        tapButton(identifier: AccessibilityID.Settings.accountAccess, fallbackLabel: "Sign in & entitlements")
        assertNavigationTitle("Account & Access")
        navigateBack()

        tapSettingsRow(identifier: AccessibilityID.Settings.firmware, fallback: "Firmware")
        assertNavigationTitle("Firmware")
        navigateBack()

        tapSettingsRow(identifier: AccessibilityID.Settings.calibration, fallback: "Calibration profiles")
        assertNavigationTitle("Calibration")
        navigateBack()

        tapSettingsRow(identifier: AccessibilityID.Settings.pairProbe, fallback: "Pair probe")
        assertNavigationTitle("Pair device")
        navigateBack()

        tapSettingsRow(identifier: AccessibilityID.Settings.testFlightStatus, fallback: "Beta build status")
        assertNavigationTitle("TestFlight")
        navigateBack()
    }

    func testHomeNewGoldScanSwitchesToScanTab() throws {
        selectTab("Home")
        tapButton(identifier: AccessibilityID.Home.newGoldScan, fallbackLabel: "New Gold Scan")
        assertNavigationTitle("Scan")
        XCTAssertTrue(app.tabBars.buttons["Scan"].isSelected)
    }

    func testFirmwareActivationOnSimulatorProbe() throws {
        selectTab("Settings")
        tapSettingsRow(identifier: AccessibilityID.Settings.firmware, fallback: "Firmware")
        assertNavigationTitle("Firmware")
        let activate = app.buttons[AccessibilityID.Firmware.activate]
        if activate.waitForExistence(timeout: 5), activate.isHittable {
            activate.tap()
        }
        let firmwareVisible =
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS '2.1.0'")).firstMatch
                .waitForExistence(timeout: 10)
            || app.staticTexts["Active"].waitForExistence(timeout: 5)
            || app.staticTexts["Not activated"].waitForExistence(timeout: 3)
        XCTAssertTrue(firmwareVisible, "Firmware screen should show version or activation state")
    }

    func testAdminPanelWhenSignedIn() throws {
        signInAsAdmin()
        selectTab("Settings")
        tapButton(identifier: AccessibilityID.Settings.adminPanel, fallbackLabel: "Admin panel")
        assertNavigationTitle("Administration")
        tapButton(identifier: AccessibilityID.Admin.testFlight, fallbackLabel: "TestFlight & subscriptions")
        assertNavigationTitle("TestFlight & Plans")
        navigateBack()
        tapButton(identifier: AccessibilityID.Admin.users, fallbackLabel: "Users")
        navigateBack()
    }

    // MARK: - Helpers

    private func tapSettingsRow(identifier: String, fallback: String) {
        let link = app.buttons[identifier]
        if link.waitForExistence(timeout: 3) {
            link.tap()
            return
        }
        app.staticTexts[fallback].tap()
    }

    private func navigateBack() {
        let back = app.navigationBars.buttons.element(boundBy: 0)
        if back.waitForExistence(timeout: 3), back.isHittable {
            back.tap()
        }
    }
}
