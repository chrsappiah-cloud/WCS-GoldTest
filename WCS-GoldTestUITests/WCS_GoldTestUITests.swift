import XCTest

/// Smoke suite — detailed coverage in TabNavigationUITests, ScanWorkflowUITests, etc.
final class WCS_GoldTestUITests: WCSUITestCase {

    func testAppLaunchesToMainInterface() throws {
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 12))
        XCTAssertEqual(app.tabBars.buttons.count, 5)
    }
}
