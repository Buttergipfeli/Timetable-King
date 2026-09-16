import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct OnboardingTests {
    @Test
    func skippingPersistsAcrossLaunchesWithoutAddingTasks() throws {
        let fixture = try OnboardingFixture()
        defer { fixture.cleanUp() }
        let viewModel = fixture.makeViewModel()

        #expect(viewModel.isShowingOnboarding)
        viewModel.completeOnboarding()

        #expect(!viewModel.isShowingOnboarding)
        #expect(fixture.store.hasCompleted)
        #expect(!fixture.makeViewModel().isShowingOnboarding)
        #expect(try fixture.service.context.fetchCount(FetchDescriptor<Habit>()) == 0)
    }

    @Test
    func existingTasksSkipIntroductionAndPreserveData() throws {
        let fixture = try OnboardingFixture()
        defer { fixture.cleanUp() }
        try WeeklyTaskService(modelContainerService: fixture.service)
            .save(title: "Existing routine", weekday: .monday, hour: 8, minute: 0)

        let viewModel = fixture.makeViewModel()

        #expect(!viewModel.isShowingOnboarding)
        #expect(fixture.store.hasCompleted)
        let tasks = try fixture.service.context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(tasks.count == 1)
        #expect(tasks.first?.habit.title == "Existing routine")
    }

    @Test
    func firstRoutineAppearsInDashboardAfterCompletion() throws {
        let fixture = try OnboardingFixture()
        defer { fixture.cleanUp() }
        let viewModel = fixture.makeViewModel()

        let saved = viewModel.addOnboardingTask(
            title: "Stretch",
            weekdays: [.current],
            hour: 8,
            minute: 15
        )
        #expect(saved)
        viewModel.completeOnboarding()

        let task = try #require(viewModel.todayEntries.first)
        #expect(task.title == "Stretch")
        #expect(task.habit.hour == 8)
        #expect(task.habit.minute == 15)
        #expect(viewModel.dashboardSnapshot.weeklyTaskCount == 1)
        #expect(!viewModel.isShowingOnboarding)
        #expect(viewModel.presentedReviewSession == nil)
    }

    @Test
    func failedSaveKeepsOnboardingOpenWithoutDuplicateTasks() throws {
        let fixture = try OnboardingFixture()
        defer { fixture.cleanUp() }
        let viewModel = fixture.makeViewModel()

        #expect(viewModel.addOnboardingTask(title: "Training", weekdays: [.monday], hour: 18, minute: 0))
        #expect(!viewModel.addOnboardingTask(title: "Training", weekdays: [.monday], hour: 18, minute: 0))

        #expect(viewModel.isShowingOnboarding)
        #expect(!fixture.store.hasCompleted)
        #expect(!viewModel.isShowingOperationError)
        #expect(try fixture.service.context.fetchCount(FetchDescriptor<WeekdayHabit>()) == 1)
    }

    @Test
    func dailyRoutineCreatesOneScheduleForEveryWeekday() throws {
        let fixture = try OnboardingFixture()
        defer { fixture.cleanUp() }
        let viewModel = fixture.makeViewModel()

        #expect(
            viewModel.addOnboardingTask(
                title: "Morning routine",
                weekdays: Set(Weekday.allCases),
                hour: 8,
                minute: 0
            )
        )
        viewModel.completeOnboarding()

        let schedules = try fixture.service.context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(schedules.count == Weekday.allCases.count)
        #expect(Set(schedules.map(\.weekday)) == Set(Weekday.allCases))
        #expect(Set(schedules.map(\.habit.title)) == ["Morning routine"])
        #expect(viewModel.dashboardSnapshot.weeklyTaskCount == Weekday.allCases.count)
    }

    @Test
    func defersReviewAndHistoryUpdatesWhileOnboardingIsVisible() throws {
        let fixture = try OnboardingFixture()
        defer { fixture.cleanUp() }
        let viewModel = fixture.makeViewModel()
        try WeeklyTaskService(modelContainerService: fixture.service)
            .save(title: "Training", weekday: .current, hour: 0, minute: 0)
        let task = try #require(fixture.service.context.fetch(FetchDescriptor<WeekdayHabit>()).first)
        task.createdAt = try #require(Calendar.current.date(byAdding: .day, value: -7, to: .now))
        try fixture.service.context.save()

        viewModel.refreshForActivation()

        #expect(viewModel.presentedReviewSession == nil)
        #expect(try fixture.service.context.fetchCount(FetchDescriptor<WeekdayHabitResult>()) == 0)

        viewModel.completeOnboarding()
        viewModel.refreshForActivation()

        #expect(viewModel.presentedReviewSession?.entries.count == 1)
        #expect(try fixture.service.context.fetchCount(FetchDescriptor<WeekdayHabitResult>()) == 1)
    }

    @Test
    func opensPendingWidgetLinkAfterOnboarding() throws {
        let fixture = try OnboardingFixture()
        defer { fixture.cleanUp() }
        let viewModel = fixture.makeViewModel()
        viewModel.open(url: TimetableDeepLink.weeklySummaryURL)

        #expect(viewModel.isShowingOnboarding)
        #expect(!viewModel.isCardPresented)

        viewModel.completeOnboarding()

        #expect(viewModel.isCardPresented)
        #expect(viewModel.presentedCard == .weeklySummary)
        #expect(!viewModel.isShowingOnboarding)
    }
}

@MainActor
private struct OnboardingFixture {
    let suiteName = "OnboardingTests.\(UUID().uuidString)"
    let userDefaults: UserDefaults
    let service: ModelContainerService

    var store: OnboardingStore {
        OnboardingStore(userDefaults: userDefaults)
    }

    init() throws {
        userDefaults = try #require(UserDefaults(suiteName: suiteName))
        let container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true)
        service = ModelContainerService(container: container)
    }

    func makeViewModel() -> TimetableKingAppViewModel {
        TimetableKingAppViewModel(
            modelContainerService: service,
            widgetSnapshotService: OnboardingWidgetSnapshotService(),
            onboardingStore: store
        )
    }

    func cleanUp() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}

@MainActor
private final class OnboardingWidgetSnapshotService: WidgetSnapshotSyncing {
    func sync(
        _ dashboardSnapshot: DashboardSnapshot,
        recurringDigests: [WeekdayDigest],
        referenceDate: Date
    ) {}
}
