import XCTest

@MainActor
final class TaskFeaturesUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTaskStatusDoesNotOfferSkipping() {
        let app = createDailyRoutine()
        let status = app.buttons["task.status.Morning routine"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        status.tap()
        XCTAssertTrue(app.buttons["Finished"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Not done"].exists)
        XCTAssertTrue(app.buttons["Undefined"].exists)
        XCTAssertFalse(app.buttons["Skipped"].exists)
    }

    func testReminderPersistsAndDeletionRequiresConfirmation() {
        let app = createDailyRoutine()
        openMonday(in: app)
        let task = app.buttons["weeklyTask.row.Morning routine"]
        XCTAssertTrue(task.waitForExistence(timeout: 5))
        task.tap()

        let reminder = app.buttons["task.reminder.picker"]
        reveal(reminder, in: app)
        reminder.tap()
        app.buttons["10 minutes before"].tap()

        let allow = XCUIApplication(bundleIdentifier: "com.apple.springboard").buttons["Allow"]
        if allow.waitForExistence(timeout: 3) {
            allow.tap()
        }

        app.buttons["weeklyTask.edit.save.button"].tap()
        XCTAssertTrue(task.waitForExistence(timeout: 5))
        task.tap()
        reveal(reminder, in: app)
        XCTAssertTrue(app.staticTexts["10 minutes before"].exists)
        attachScreenshot(app, name: "Task reminder")

        let delete = app.buttons["weeklyTask.delete.button"]
        reveal(delete, in: app)
        delete.tap()
        XCTAssertTrue(app.buttons["Delete series"].waitForExistence(timeout: 3))
        attachScreenshot(app, name: "Delete series confirmation")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["weeklyTask.edit.save.button"].exists)

        delete.tap()
        app.buttons["Delete series"].tap()
        XCTAssertTrue(app.staticTexts["No Tasks"].waitForExistence(timeout: 5))
        XCTAssertFalse(task.exists)
    }

    func testSwipeDeletionRequiresConfirmation() {
        let app = createDailyRoutine()
        openMonday(in: app)
        let task = app.buttons["weeklyTask.row.Morning routine"]
        XCTAssertTrue(task.waitForExistence(timeout: 5))
        task.swipeLeft()
        app.buttons["Delete Task"].tap()
        XCTAssertTrue(app.buttons["Delete series"].waitForExistence(timeout: 3))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(task.exists)

        task.swipeLeft()
        app.buttons["Delete Task"].tap()
        app.buttons["Delete series"].tap()
        XCTAssertTrue(app.staticTexts["No Tasks"].waitForExistence(timeout: 5))
    }

    private func createDailyRoutine() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--empty-store", "--reset-onboarding",
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US"
        ]
        app.launch()
        XCTAssertTrue(app.buttons["onboarding.start.button"].waitForExistence(timeout: 5))
        app.buttons["onboarding.start.button"].tap()
        app.buttons["onboarding.template.morning.button"].tap()
        app.buttons["onboarding.routine.save.button"].tap()
        XCTAssertTrue(app.buttons["dashboard.settings.button"].waitForExistence(timeout: 5))
        return app
    }

    private func openMonday(in app: XCUIApplication) {
        let weeklyPlan = app.buttons["dashboard.weeklyPlan.button"]
        reveal(weeklyPlan, in: app)
        weeklyPlan.tap()
        let monday = app.buttons["weeklyTasks.monday.button"]
        XCTAssertTrue(monday.waitForExistence(timeout: 5))
        monday.tap()
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 where !element.exists || !element.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }

    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
