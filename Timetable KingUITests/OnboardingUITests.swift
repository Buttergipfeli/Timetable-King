import XCTest

final class OnboardingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSkipsOnboardingOnlyOnce() {
        let app = launchFirstRun()
        app.buttons["onboarding.skip.button"].tap()
        XCTAssertTrue(app.buttons["dashboard.settings.button"].waitForExistence(timeout: 5))

        app.terminate()
        app.launchArguments.removeAll { $0 == "--reset-onboarding" }
        app.launch()

        XCTAssertTrue(app.buttons["dashboard.settings.button"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["onboarding.start.button"].exists)
    }

    @MainActor
    func testCreatesRoutineFromEditableTemplate() {
        let app = launchFirstRun()
        app.buttons["onboarding.start.button"].tap()

        let saveButton = app.buttons["onboarding.routine.save.button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertFalse(saveButton.isEnabled)

        app.buttons["onboarding.template.morning.button"].tap()
        let titleField = app.textFields["onboarding.routine.title.field"]
        XCTAssertEqual(titleField.value as? String, "Morning routine")
        XCTAssertTrue(saveButton.isEnabled)

        titleField.tap()
        titleField.typeText(" test")
        saveButton.tap()

        XCTAssertTrue(app.buttons["dashboard.settings.button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Morning routine test"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["onboarding.start.button"].exists)
    }

    @MainActor
    func testCreatesCustomRoutineAndRejectsBlankTitle() {
        let app = launchFirstRun()
        app.buttons["onboarding.start.button"].tap()

        let titleField = app.textFields["onboarding.routine.title.field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("   ")
        XCTAssertFalse(app.buttons["onboarding.routine.save.button"].isEnabled)
        titleField.typeText("Read ten pages")
        app.buttons["onboarding.routine.save.button"].tap()

        XCTAssertTrue(app.buttons["dashboard.settings.button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Read ten pages"].firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor
    func testCanReopenIntroductionAndCancelWithoutCreatingTask() {
        let app = launchFirstRun()
        app.buttons["onboarding.skip.button"].tap()
        let settingsButton = app.buttons["dashboard.settings.button"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        app.buttons["settings.onboarding.button"].tap()

        XCTAssertTrue(app.buttons["onboarding.start.button"].waitForExistence(timeout: 5))
        app.buttons["onboarding.start.button"].tap()
        app.buttons["onboarding.template.training.button"].tap()
        app.buttons["onboarding.skip.button"].tap()

        XCTAssertTrue(app.buttons["settings.onboarding.button"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["onboarding.routine.save.button"].exists)
    }

    @MainActor
    func testGermanIntroductionAndTemplate() {
        let app = launchFirstRun(language: "de", locale: "de_CH")
        XCTAssertTrue(app.staticTexts["Deine Woche.\nDein Rhythmus."].exists)
        let welcome = XCTAttachment(screenshot: app.screenshot())
        welcome.name = "Onboarding German Welcome"
        welcome.lifetime = .keepAlways
        add(welcome)

        app.buttons["onboarding.start.button"].tap()
        app.buttons["onboarding.template.household.button"].tap()
        XCTAssertEqual(app.textFields["onboarding.routine.title.field"].value as? String, "Haushalt erledigen")
        let routine = XCTAttachment(screenshot: app.screenshot())
        routine.name = "Onboarding German Routine"
        routine.lifetime = .keepAlways
        add(routine)
    }

    @MainActor
    private func launchFirstRun(language: String = "en", locale: String = "en_US") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--empty-store", "--reset-onboarding",
            "-AppleLanguages", "(\(language))", "-AppleLocale", locale
        ]
        app.launch()
        XCTAssertTrue(app.buttons["onboarding.start.button"].waitForExistence(timeout: 5))
        return app
    }
}
