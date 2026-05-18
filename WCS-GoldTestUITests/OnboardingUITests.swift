import XCTest

final class OnboardingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingSkipReachesMainTabs() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        let skip = app.buttons[AccessibilityID.Onboarding.skip]
        if skip.waitForExistence(timeout: 5) {
            skip.tap()
        }

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Scan"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    @MainActor
    func testOnboardingContinueFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        guard app.buttons[AccessibilityID.Onboarding.continueButton].waitForExistence(timeout: 5) else {
            throw XCTSkip("Onboarding already completed")
        }

        app.buttons[AccessibilityID.Onboarding.continueButton].tap()
        app.buttons[AccessibilityID.Onboarding.continueButton].tap()
        app.buttons[AccessibilityID.Onboarding.getStarted].tap()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))
    }
}
