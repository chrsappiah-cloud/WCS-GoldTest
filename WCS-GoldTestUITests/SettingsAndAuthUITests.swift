import XCTest

final class SettingsAndAuthUITests: WCSUITestCase {

    func testSettingsButtonsRespond() throws {
        selectTab("Settings")
        tapButton(identifier: AccessibilityID.Settings.accountAccess, fallbackLabel: "Sign in & entitlements")
        assertNavigationTitle("Account & Access")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        tapButton(identifier: AccessibilityID.Settings.upgradeSubscription, fallbackLabel: "Upgrade subscription")
        assertNavigationTitle("Premium")
    }

    func testAdminSignInShowsAdminPanel() throws {
        signInAsAdmin()
        selectTab("Settings")
        let adminLink = app.buttons[AccessibilityID.Settings.adminPanel]
        XCTAssertTrue(
            adminLink.waitForExistence(timeout: 10)
                || app.staticTexts["Admin panel"].waitForExistence(timeout: 10),
            "Admin panel should appear for administrator"
        )
    }

    func testRestorePurchasesTappable() throws {
        selectTab("Settings")
        let restore = app.buttons[AccessibilityID.Settings.restorePurchases]
        if restore.waitForExistence(timeout: 3) {
            restore.tap()
        } else {
            app.buttons["Restore purchases"].tap()
        }
    }
}
