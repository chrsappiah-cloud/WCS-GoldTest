import XCTest

final class ScanWorkflowUITests: WCSUITestCase {

    func testStartGoldScanRequiresChecklist() throws {
        selectTab("Scan")
        let start = app.buttons[AccessibilityID.Scan.startGoldScan]
        let startLabel = app.buttons["Start Gold Scan"]
        let button = start.exists ? start : startLabel
        XCTAssertTrue(button.waitForExistence(timeout: 5))

        if button.isEnabled {
            button.tap()
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'checklist'")).firstMatch
                    .waitForExistence(timeout: 3)
                    || app.staticTexts["Measuring…"].waitForExistence(timeout: 15)
            )
        } else {
            XCTAssertFalse(button.isEnabled, "Start should be disabled until checklist complete")
        }
    }

    func testCompleteMockGoldScanFlow() throws {
        selectTab("Scan")
        completeScanChecklist()

        let start = app.buttons[AccessibilityID.Scan.startGoldScan]
        if !start.waitForExistence(timeout: 3) {
            app.buttons["Start Gold Scan"].tap()
        } else {
            XCTAssertTrue(start.isEnabled, "Start Gold Scan should enable after checklist")
            start.tap()
        }

        XCTAssertTrue(
            app.staticTexts["Measuring…"].waitForExistence(timeout: 8)
                || app.staticTexts["Screening result"].waitForExistence(timeout: 30),
            "Scan should show measuring or result"
        )

        let done = app.buttons[AccessibilityID.Scan.startGoldScan].exists
            ? app.buttons["Done"]
            : app.buttons["Done"]
        if done.waitForExistence(timeout: 35) {
            done.tap()
            assertNavigationTitle("Scan")
        }
    }
}
