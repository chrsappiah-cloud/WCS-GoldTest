import XCTest

class WCSUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-ui-testing", "-skipOnboarding", "-inMemoryStore", "-mockBLE"]
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
        _ = app.tabBars.buttons["Home"].waitForExistence(timeout: 5)
    }

    // MARK: - Tab bar

    @discardableResult
    func selectTab(_ name: String, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let tab = app.tabBars.buttons[name]
        XCTAssertTrue(tab.waitForExistence(timeout: 8), "Tab '\(name)' not found", file: file, line: line)
        tab.tap()
        return tab
    }

    func assertNavigationTitle(_ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let nav = app.navigationBars[title]
        XCTAssertTrue(nav.waitForExistence(timeout: 5), "Navigation title '\(title)' missing", file: file, line: line)
    }

    func tapButton(identifier: String, fallbackLabel: String? = nil, file: StaticString = #filePath, line: UInt = #line) {
        let byId = app.buttons[identifier]
        if byId.waitForExistence(timeout: 3) {
            byId.tap()
            return
        }
        if let label = fallbackLabel {
            let byLabel = app.buttons[label]
            XCTAssertTrue(byLabel.waitForExistence(timeout: 5), "Button '\(label)' missing", file: file, line: line)
            byLabel.tap()
            return
        }
        XCTFail("Button '\(identifier)' not found", file: file, line: line)
    }

    func tapSwitch(identifier: String, fallbackLabel: String, file: StaticString = #filePath, line: UInt = #line) {
        let sw = app.switches[identifier]
        if sw.waitForExistence(timeout: 3) {
            sw.tap()
            return
        }
        let byLabel = app.switches[fallbackLabel]
        XCTAssertTrue(byLabel.waitForExistence(timeout: 5), "Switch '\(fallbackLabel)' missing", file: file, line: line)
        byLabel.tap()
    }

    func typeText(_ text: String, in fieldId: String, fallbackPlaceholder: String? = nil) {
        let field = app.textFields[fieldId]
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.clearAndType(text)
            return
        }
        if let placeholder = fallbackPlaceholder {
            let alt = app.textFields[placeholder]
            XCTAssertTrue(alt.waitForExistence(timeout: 8))
            alt.tap()
            alt.clearAndType(text)
        }
    }

    func typeSecure(_ text: String, identifier: String, fallbackLabel: String = "Password") {
        let field = app.secureTextFields[identifier]
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.clearAndType(text)
            return
        }
        let alt = app.secureTextFields[fallbackLabel]
        XCTAssertTrue(alt.waitForExistence(timeout: 8))
        alt.tap()
        alt.clearAndType(text)
    }

    func dismissKeyboardIfNeeded() {
        app.tap()
        if app.keyboards.keys["return"].exists {
            app.keyboards.keys["return"].tap()
        } else if app.keyboards.buttons["Return"].exists {
            app.keyboards.buttons["Return"].tap()
        } else if app.toolbars.buttons["Done"].exists {
            app.toolbars.buttons["Done"].tap()
        }
    }

    func scrollToReveal(_ element: XCUIElement, in scrollable: XCUIElement? = nil, maxSwipes: Int = 12) {
        let container = scrollable ?? settingsScrollView()
        var swipes = 0
        while swipes < maxSwipes {
            if element.exists, element.isHittable { return }
            container.swipeUp()
            swipes += 1
        }
    }

    func settingsScrollView() -> XCUIElement {
        if app.tables.firstMatch.exists { return app.tables.firstMatch }
        if app.collectionViews.firstMatch.exists { return app.collectionViews.firstMatch }
        if app.scrollViews.firstMatch.exists { return app.scrollViews.firstMatch }
        return app
    }

    func scrollSettingsToTop(maxSwipes: Int = 10) {
        let scrollable = settingsScrollView()
        for _ in 0..<maxSwipes {
            scrollable.swipeDown()
        }
    }

    func tapSettingsRow(identifier: String, fallback: String, file: StaticString = #filePath, line: UInt = #line) {
        scrollSettingsToTop()
        let scrollable = settingsScrollView()

        for _ in 0..<12 {
            let byId = app.buttons[identifier]
            if byId.exists, byId.isHittable {
                byId.tap()
                return
            }

            let byLabel = app.buttons[fallback]
            if byLabel.exists, byLabel.isHittable {
                byLabel.tap()
                return
            }

            let text = app.staticTexts[fallback]
            if text.exists, text.isHittable {
                text.tap()
                return
            }

            let cell = app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", fallback)).firstMatch
            if cell.exists, cell.isHittable {
                cell.tap()
                return
            }

            scrollable.swipeUp()
        }

        XCTFail("Settings row '\(fallback)' missing", file: file, line: line)
    }

    func completeScanChecklist() {
        tapSwitch(identifier: AccessibilityID.Scan.checklistToggle, fallbackLabel: "Probe cleaned and seated")
        tapSwitch(identifier: AccessibilityID.Scan.surfaceDryToggle, fallbackLabel: "Item surface dry and accessible")
        tapSwitch(identifier: AccessibilityID.Scan.stableHandToggle, fallbackLabel: "Stable hand position")
    }

    func signInAsAdmin() {
        selectTab("Settings")
        tapButton(identifier: AccessibilityID.Settings.accountAccess, fallbackLabel: "Sign in & entitlements")
        XCTAssertTrue(app.navigationBars["Account & Access"].waitForExistence(timeout: 8))

        // If already authenticated (forceAdminAuth during UI testing), just verify signed-in panel
        if app.buttons[AccessibilityID.Auth.signOut].waitForExistence(timeout: 3) {
            if app.navigationBars.buttons.element(boundBy: 0).exists {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            }
            return
        }

        let scroll = app.scrollViews.firstMatch
        if scroll.exists { scroll.swipeUp() }

        typeText("admin@wcsgold.test", in: AccessibilityID.Auth.email, fallbackPlaceholder: "Email")
        typeSecure("WCSAdmin2026!", identifier: AccessibilityID.Auth.password)
        dismissKeyboardIfNeeded()

        if scroll.exists { scroll.swipeUp() }

        let signIn = app.buttons[AccessibilityID.Auth.signIn]
        if signIn.waitForExistence(timeout: 8), signIn.isHittable {
            signIn.tap()
        } else if app.buttons["Sign in"].waitForExistence(timeout: 5) {
            app.buttons["Sign in"].tap()
        } else if app.buttons["key.fill"].exists {
            app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sign in'")).firstMatch.tap()
        }

        XCTAssertTrue(
            app.buttons[AccessibilityID.Auth.signOut].waitForExistence(timeout: 20)
                || app.staticTexts["WCS Administrator"].waitForExistence(timeout: 20)
                || app.staticTexts["admin@wcsgold.test"].waitForExistence(timeout: 20),
            "Admin sign-in should complete"
        )

        if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
}

private extension XCUIElement {
    func clearAndType(_ text: String) {
        guard let stringValue = value as? String else {
            typeText(text)
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString + text)
    }
}
