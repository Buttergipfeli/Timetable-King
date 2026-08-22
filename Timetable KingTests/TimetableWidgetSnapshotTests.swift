import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct TimetableWidgetSnapshotTests {
    @Test
    func storePersistsSnapshot() throws {
        let suiteName = "TimetableWidgetSnapshotTests.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        let store = TimetableWidgetSnapshotStore(userDefaults: userDefaults)
        let snapshot = TimetableWidgetSnapshot.placeholder()

        store.save(snapshot)

        #expect(store.load() == snapshot)
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test
    func upcomingTasksContainOnlyOpenTasksInScheduleOrder() {
        let snapshot = TimetableWidgetSnapshot.placeholder()

        #expect(snapshot.upcomingTasks.map(\.title) == ["Team stand-up", "Deep work"])
        #expect(snapshot.nextTask?.title == "Team stand-up")
    }

    @Test
    func emptySnapshotContainsNoRuntimeSampleData() {
        let snapshot = TimetableWidgetSnapshot.empty()

        #expect(snapshot.todayTasks.isEmpty)
        #expect(snapshot.weeklyTotalCount == 0)
        #expect(snapshot.nextTask == nil)
    }

    @Test
    func resolvingSnapshotSelectsTasksForTheNewDay() throws {
        let calendar = Calendar(identifier: .gregorian)
        let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 8, day: 17, hour: 12)))
        let tuesday = try #require(calendar.date(byAdding: .day, value: 1, to: monday))
        let task = TimetableWidgetTask(
            id: "tuesday-task",
            title: "Tuesday task",
            hour: 8,
            minute: 0,
            status: .todo
        )
        let snapshot = TimetableWidgetSnapshot(
            generatedAt: monday,
            weekStart: TimetableWidgetSnapshot.weekStart(for: monday, calendar: calendar),
            week: [
                TimetableWidgetDay(id: "monday", weekdayIndex: 1, label: "Mon", tasks: []),
                TimetableWidgetDay(id: "tuesday", weekdayIndex: 2, label: "Tue", tasks: [task])
            ],
            recurringWeek: []
        )

        let resolvedSnapshot = snapshot.resolved(for: tuesday, calendar: calendar)

        #expect(resolvedSnapshot.todayTasks == [task])
    }

    @Test
    func resolvingSnapshotForNewWeekUsesRecurringTasks() throws {
        let calendar = Calendar(identifier: .gregorian)
        let monday = try #require(calendar.date(from: DateComponents(year: 2026, month: 8, day: 17, hour: 12)))
        let nextMonday = try #require(calendar.date(byAdding: .day, value: 7, to: monday))
        let completedTask = TimetableWidgetTask(
            id: "weekly-task",
            title: "Weekly task",
            hour: 8,
            minute: 0,
            status: .done
        )
        let recurringTask = completedTask.resettingStatus()
        let snapshot = TimetableWidgetSnapshot(
            generatedAt: monday,
            weekStart: TimetableWidgetSnapshot.weekStart(for: monday, calendar: calendar),
            week: [
                TimetableWidgetDay(
                    id: "monday",
                    weekdayIndex: 1,
                    label: "Mon",
                    tasks: [completedTask]
                )
            ],
            recurringWeek: [
                TimetableWidgetDay(
                    id: "monday",
                    weekdayIndex: 1,
                    label: "Mon",
                    tasks: [recurringTask]
                )
            ]
        )

        let resolvedSnapshot = snapshot.resolved(for: nextMonday, calendar: calendar)

        #expect(resolvedSnapshot.weeklyCompletedCount == 0)
        #expect(resolvedSnapshot.nextTask?.status == .todo)
    }

    @Test
    func failedTasksDoNotCountAsCompletedOrOpen() {
        let referenceDate = Date.now
        let weekdayIndex = TimetableWidgetSnapshot.weekdayIndex(for: referenceDate)
        let failedTask = TimetableWidgetTask(
            id: "failed-task",
            title: "Failed task",
            hour: 8,
            minute: 0,
            status: .failed
        )
        let snapshot = TimetableWidgetSnapshot(
            generatedAt: referenceDate,
            weekStart: TimetableWidgetSnapshot.weekStart(for: referenceDate),
            week: [
                TimetableWidgetDay(
                    id: "today",
                    weekdayIndex: weekdayIndex,
                    label: "Today",
                    tasks: [failedTask]
                )
            ],
            recurringWeek: []
        )

        #expect(snapshot.nextTask == nil)
        #expect(snapshot.isTodayComplete == false)
        #expect(snapshot.dailyProgress == 0)
    }

    @Test
    func weekStartUsesTheConfiguredCalendar() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        let monday = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 8, day: 17, hour: 12))
        )
        let expectedSunday = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 8, day: 16))
        )

        let weekStart = TimetableWidgetSnapshot.weekStart(for: monday, calendar: calendar)

        #expect(weekStart == expectedSunday)
    }

    @Test
    func deepLinksPreserveTaskIdentifiers() {
        let taskID = "saturday-23-0-Evening stretch"
        let url = TimetableDeepLink.taskURL(taskID: taskID)

        #expect(TimetableDeepLink.destination(for: url) == .task(taskID))
        #expect(TimetableDeepLink.destination(for: TimetableDeepLink.todayTasksURL) == .todayTasks)
        #expect(TimetableDeepLink.destination(for: TimetableDeepLink.weeklySummaryURL) == .weeklySummary)
    }

    @Test
    func appRoutesTaskDeepLinkToMatchingEntry() throws {
        let container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true)
        let modelContainerService = ModelContainerService(container: container)
        let habit = Habit(title: "Open from widget")
        let schedule = WeekdayHabit(
            hour: 12,
            minute: 30,
            weekdayRawValue: Weekday.current.rawValue,
            habit: habit
        )
        schedule.createdAt = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        container.mainContext.insert(habit)
        container.mainContext.insert(schedule)
        try container.mainContext.save()
        let viewModel = TimetableKingAppViewModel(
            modelContainerService: modelContainerService,
            widgetSnapshotService: NoOpWidgetSnapshotService()
        )
        viewModel.load()
        let entry = try #require(viewModel.todayEntries.first)

        viewModel.open(url: TimetableDeepLink.taskURL(taskID: entry.widgetIdentifier))

        #expect(viewModel.presentedEntry?.widgetIdentifier == entry.widgetIdentifier)
        #expect(viewModel.isCardPresented == false)
    }
}

@MainActor
private final class NoOpWidgetSnapshotService: WidgetSnapshotSyncing {
    func sync(
        _ dashboardSnapshot: DashboardSnapshot,
        recurringDigests: [WeekdayDigest],
        referenceDate: Date
    ) { }
}
