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
        XCTAssertTrue(app.buttons["weekday.selection.everyDay.button"].isSelected)
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
    func testCreatesDailyTaskFromDashboard() {
        let app = launchFirstRun()
        app.buttons["onboarding.skip.button"].tap()

        let addButton = app.buttons["dashboard.addTask.button"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        for _ in 0..<5 where !addButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(addButton.isHittable)
        addButton.tap()

        let titleField = app.textFields["weeklyTask.add.title.field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Drink water")

        let everyDayButton = app.buttons["weekday.selection.everyDay.button"]
        everyDayButton.tap()
        XCTAssertTrue(everyDayButton.isSelected)
        app.buttons["weeklyTask.add.save.button"].tap()

        XCTAssertTrue(app.staticTexts["Drink water"].firstMatch.waitForExistence(timeout: 5))
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
    func testGermanIntroductionWithLargeText() {
        let app = launchFirstRun(
            language: "de",
            locale: "de_CH",
            additionalArguments: [
                "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
            ]
        )
        let welcome = XCTAttachment(screenshot: app.screenshot())
        welcome.name = "Onboarding Large Text Welcome"
        welcome.lifetime = .keepAlways
        add(welcome)

        app.buttons["onboarding.start.button"].tap()
        let templateButton = app.buttons["onboarding.template.training.button"]
        XCTAssertTrue(templateButton.waitForExistence(timeout: 5))
        templateButton.tap()

        let saveButton = app.buttons["onboarding.routine.save.button"]
        XCTAssertTrue(saveButton.isHittable)
        let routine = XCTAttachment(screenshot: app.screenshot())
        routine.name = "Onboarding Large Text Routine"
        routine.lifetime = .keepAlways
        add(routine)
        saveButton.tap()

        XCTAssertTrue(app.buttons["dashboard.settings.button"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func launchFirstRun(
        language: String = "en",
        locale: String = "en_US",
        additionalArguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--empty-store", "--reset-onboarding",
            "-AppleLanguages", "(\(language))", "-AppleLocale", locale
        ] + additionalArguments
        app.launch()
        XCTAssertTrue(app.buttons["onboarding.start.button"].waitForExistence(timeout: 5))
        return app
    }
}
