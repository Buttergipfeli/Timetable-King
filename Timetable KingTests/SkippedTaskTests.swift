import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct SkippedTaskTests {
    @Test
    func skipIsNeutralInDashboardWeeklyHistoryAndWidgets() async throws {
        let service = ModelContainerService(container: Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true))
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Read", weekday: .current, hour: 8, minute: 0)
        try taskService.save(title: "Walk", weekday: .current, hour: 9, minute: 0)
        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        let read = try #require(schedules.first { $0.habit.title == "Read" })
        let walk = try #require(schedules.first { $0.habit.title == "Walk" })
        let reviewService = TodayTaskReviewService(modelContainerService: service)
        try reviewService.setStatus(.done, for: read, on: .now)
        try reviewService.setStatus(.skipped, for: walk, on: .now)

        let suiteName = "SkippedTaskTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let widgetStore = TimetableWidgetSnapshotStore(userDefaults: defaults)
        let app = TimetableKingAppViewModel(
            modelContainerService: service,
            widgetSnapshotService: WidgetSnapshotService(store: widgetStore),
            onboardingStore: OnboardingStore(userDefaults: defaults)
        )
        app.load()
        #expect(app.dashboardSnapshot.completedTodayCount == 1)
        #expect(app.dashboardSnapshot.totalTodayCount == 1)
        #expect(app.dashboardSnapshot.weeklyCompletionPercentage == 1)
        #expect(app.dashboardSnapshot.progress(for: .current).isComplete)
        #expect(app.todayEntries.count == 2)
        #expect(widgetStore.load()?.totalTodayCount == 1)
        #expect(widgetStore.load()?.todayTasks.first { $0.title == "Walk" }?.status == .skipped)

        let history = WeeklySummaryViewModel(modelContainerService: service)
        await history.loadAvailableWeeks()
        let week = try #require(history.availableWeeks.first)
        #expect(history.score(for: week).completionPercentage == 1)
        #expect(history.overallScore.completionPercentage == 1)
        #expect(history.entries(for: week).first { $0.isCurrentDay }?.totalCount == 1)

        let today = TodayTasksViewModel()
        today.map(todayDigest: app.todayDigest)
        #expect(today.skippedEntries.map(\.title) == ["Walk"])
        #expect(today.finishedEntries.map(\.title) == ["Read"])
        #expect(today.todoEntries.isEmpty)

        let readEntry = try #require(app.todayEntries.first { $0.title == "Read" })
        #expect(app.updateTodayTaskStatus(for: readEntry, status: .skipped))
        #expect(app.dashboardSnapshot.weeklyTotalCount == 0)
        #expect(app.dashboardSnapshot.weeklySkippedCount == 2)
        #expect(app.dashboardSnapshot.progress(for: .current).skippedCount == 2)
    }

    @Test
    func skippedOccurrenceSurvivesDeletionAndAutomaticFailureResolution() throws {
        let service = ModelContainerService(container: Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true))
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Walk", weekday: .current, hour: 8, minute: 0)
        let schedule = try #require(service.context.fetch(FetchDescriptor<WeekdayHabit>()).first)
        let review = TodayTaskReviewService(modelContainerService: service)
        try review.setStatus(.skipped, for: schedule, on: .now)
        try taskService.delete(habit: schedule)
        let tomorrow = try #require(Calendar.current.date(byAdding: .day, value: 1, to: .now))
        #expect(try review.resolvePastUndefinedTasks(referenceDate: tomorrow) == 0)
        #expect(review.fetchPendingReviewEntries().isEmpty)

        let results = try ModelContext(service.modelContainer).fetch(FetchDescriptor<WeekdayHabitResult>())
        #expect(results.count == 1)
        #expect(results.first?.status == .skipped)
        #expect(results.first?.weekdayHabit.habit.title == "Walk")
    }

    @Test
    func skippedTaskCanBeReopened() throws {
        let service = ModelContainerService(container: Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true))
        try WeeklyTaskService(modelContainerService: service).save(title: "Walk", weekday: .current, hour: 0, minute: 0)
        let schedule = try #require(service.context.fetch(FetchDescriptor<WeekdayHabit>()).first)
        let review = TodayTaskReviewService(modelContainerService: service)
        try review.setStatus(.skipped, for: schedule, on: .now)
        #expect(review.fetchPendingReviewEntries().isEmpty)
        try review.setStatus(.none, for: schedule, on: .now)
        #expect(review.fetchPendingReviewEntries().count == 1)
        #expect(try service.context.fetchCount(FetchDescriptor<WeekdayHabitResult>()) == 0)
    }
}
