import XCTest

final class AdminPanelUITests: WCSUITestCase {

    func testAdminDashboardNavigation() throws {
        signInAsAdmin()
        let settings = app.tables.firstMatch
        if settings.exists {
            settings.swipeUp()
        }
        tapButton(identifier: AccessibilityID.Settings.adminPanel, fallbackLabel: "Admin panel")
        assertNavigationTitle("Administration")

        tapButton(identifier: AccessibilityID.Admin.users, fallbackLabel: "User access control")
        assertNavigationTitle("Users")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        tapButton(identifier: AccessibilityID.Admin.entitlements, fallbackLabel: "Feature entitlements by plan")
        assertNavigationTitle("Entitlements")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        tapButton(identifier: AccessibilityID.Admin.testFlight, fallbackLabel: "TestFlight & subscriptions")
        assertNavigationTitle("TestFlight & Plans")
    }

    func testAdminSeesSeededUsers() throws {
        signInAsAdmin()
        let settings = app.tables.firstMatch
        if settings.exists {
            settings.swipeUp()
        }
        tapButton(identifier: AccessibilityID.Settings.adminPanel, fallbackLabel: "Admin panel")
        tapButton(identifier: AccessibilityID.Admin.users, fallbackLabel: "User access control")
        XCTAssertTrue(app.staticTexts["admin@wcsgold.test"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["testflight@wcsgold.test"].exists)
    }
}
