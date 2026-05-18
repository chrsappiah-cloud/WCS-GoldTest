import XCTest

final class TabNavigationUITests: WCSUITestCase {

    func testAllPrimaryTabsExistAndNavigate() throws {
        for tab in ["Home", "Scan", "Vault", "Reports", "Settings"] {
            selectTab(tab)
            XCTAssertTrue(app.tabBars.buttons[tab].isSelected, "\(tab) should be selected")
        }
    }

    func testHomeScreenShowsDeviceStatus() throws {
        selectTab("Home")
        assertNavigationTitle("Home")
        XCTAssertTrue(app.staticTexts["Device status"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Last calibration"].exists)
        XCTAssertTrue(app.staticTexts["Subscription"].exists)
    }

    func testHomePairDeviceNavigation() throws {
        selectTab("Home")
        tapButton(identifier: AccessibilityID.Home.pairDevice, fallbackLabel: "Pair Device")
        assertNavigationTitle("Pair device")
    }

    func testScanScreenShowsMaterialAndChecklist() throws {
        selectTab("Scan")
        assertNavigationTitle("Scan")
        XCTAssertTrue(app.staticTexts["Material"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Pre-scan checklist"].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Scan.startGoldScan].waitForExistence(timeout: 5)
            || app.buttons["Start Gold Scan"].exists)
    }

    func testVaultScreenLoads() throws {
        selectTab("Vault")
        assertNavigationTitle("Vault")
        XCTAssertTrue(
            app.staticTexts["No saved items"].waitForExistence(timeout: 5)
                || app.searchFields.firstMatch.exists
        )
    }

    func testReportsScreenLoads() throws {
        selectTab("Reports")
        assertNavigationTitle("Reports")
        XCTAssertTrue(
            app.staticTexts["No reports yet"].waitForExistence(timeout: 5)
                || app.staticTexts["Reports locked"].exists
        )
    }

    func testSettingsScreenShowsAccountSection() throws {
        selectTab("Settings")
        assertNavigationTitle("Settings")
        XCTAssertTrue(app.staticTexts["Account & access"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons[AccessibilityID.Settings.accountAccess].exists
            || app.staticTexts["Sign in & entitlements"].exists)
    }
}
