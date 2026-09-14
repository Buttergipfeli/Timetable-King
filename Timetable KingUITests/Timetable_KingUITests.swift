import XCTest

final class Timetable_KingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testGeneratesNewPaletteFromSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--demo-data", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        dismissReviewIfPresented(in: app)

        let settingsButton = app.buttons["dashboard.settings.button"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let paletteIdentifier = app.staticTexts["settings.palette.identifier"]
        XCTAssertTrue(paletteIdentifier.waitForExistence(timeout: 5))
        let originalIdentifier = paletteIdentifier.label

        app.buttons["settings.palette.generate.button"].tap()

        XCTAssertNotEqual(paletteIdentifier.label, originalIdentifier)
    }

    @MainActor
    func testOpensWeeklyHistory() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--demo-data", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        dismissReviewIfPresented(in: app)

        let weeklySummaryButton = app.buttons["dashboard.weeklySummary.button"]
        XCTAssertTrue(weeklySummaryButton.waitForExistence(timeout: 5))
        weeklySummaryButton.tap()

        let overallCard = app.descendants(matching: .any)["weeklySummary.overall.card"]
        XCTAssertTrue(overallCard.waitForExistence(timeout: 5))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Weekly History"
        attachment.lifetime = .keepAlways
        add(attachment)

        let pageControl = app.descendants(matching: .any)["weeklySummary.pageControl"]
        XCTAssertTrue(pageControl.waitForExistence(timeout: 5))
        pageControl.press(forDuration: 0.8)

        let weekPickerTitle = app.navigationBars["Jump to week"]
        XCTAssertTrue(weekPickerTitle.waitForExistence(timeout: 5))

        let pickerAttachment = XCTAttachment(screenshot: app.screenshot())
        pickerAttachment.name = "Week Picker"
        pickerAttachment.lifetime = .keepAlways
        add(pickerAttachment)

        app.buttons["Oldest week"].tap()
        XCTAssertTrue(weekPickerTitle.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testOpensSelectedWeekdayFromWeeklySummary() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--demo-data", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        dismissReviewIfPresented(in: app)

        let saturdayButton = app.buttons["dashboard.weeklySummary.saturday.button"]
        XCTAssertTrue(saturdayButton.waitForExistence(timeout: 5))
        saturdayButton.tap()

        XCTAssertTrue(app.navigationBars["Saturday"].waitForExistence(timeout: 5))
        let weekdaySheet = app.descendants(matching: .any)["weeklySummary.weekday.sheet"]
        XCTAssertTrue(weekdaySheet.exists)
    }

    @MainActor
    func testNavigatesToSelectedWeekdayWithinWeeklySummary() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--demo-data", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        dismissReviewIfPresented(in: app)

        let weeklySummaryButton = app.buttons["dashboard.weeklySummary.button"]
        XCTAssertTrue(weeklySummaryButton.waitForExistence(timeout: 5))
        weeklySummaryButton.tap()

        let thursdayButton = app.buttons["weeklySummary.thursday.button"].firstMatch
        XCTAssertTrue(thursdayButton.waitForExistence(timeout: 5))
        thursdayButton.tap()

        let navigationBar = app.navigationBars["Thursday"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        XCTAssertTrue(navigationBar.buttons["Weekly Summary"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["--demo-data"]
            app.launch()
        }
    }

    private func dismissReviewIfPresented(in app: XCUIApplication) {
        for _ in 0..<10 {
            let laterButton = app.buttons["todayReview.later.button"]
            guard laterButton.waitForExistence(timeout: 1) else { return }

            let enabledExpectation = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "enabled == true"),
                object: laterButton
            )
            guard XCTWaiter.wait(for: [enabledExpectation], timeout: 2) == .completed else { return }
            laterButton.tap()
        }
    }
}
