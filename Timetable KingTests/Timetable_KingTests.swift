import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct Timetable_KingTests {
    @Test
    func keepsSameDayResultsVisibleAfterHistoryDeletion() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let now = Date.now
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.current.rawValue,
            habit: habit
        )
        schedule.createdAt = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        let result = WeekdayHabitResult(day: now, weekdayHabit: schedule, status: .failed)

        context.insert(habit)
        context.insert(schedule)
        context.insert(result)
        try context.save()

        try HistoryStateService(modelContainerService: modelContainerService).markHistoryDeleted(at: now)
        result.status = .done
        try context.save()

        let digest = WeekdayDigestService(modelContainerService: modelContainerService)
            .fetchWeekdayDigests()?
            .first(where: { $0.weekday == .current })

        #expect(digest?.results.count == 1)
        #expect(digest?.results.first?.status == .done)
    }

    @Test
    func hidesEarlierDaysOfResetWeekAfterHistoryDeletion() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let weekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let resetDate = try #require(Calendar.current.date(byAdding: .day, value: 3, to: weekStart))
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.monday.rawValue,
            habit: habit
        )
        schedule.createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: weekStart)
        )

        context.insert(habit)
        context.insert(schedule)
        try context.save()
        try HistoryStateService(modelContainerService: modelContainerService).markHistoryDeleted(at: resetDate)

        let interval = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: weekStart))
        let monday = WeekdayDigestService(modelContainerService: modelContainerService)
            .fetchWeekdayDigests(for: interval)?
            .first(where: { $0.weekday == .monday })

        #expect(monday?.isEmpty == true)
    }

    @Test
    func keepsHistoricalResultOnItsRecordedDayAfterScheduleMoves() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let currentWeekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let previousWeekStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)
        )
        let previousWednesday = try #require(date(for: .wednesday, inWeekStartingAt: previousWeekStart))
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.wednesday.rawValue,
            habit: habit
        )
        schedule.createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: previousWeekStart)
        )

        context.insert(habit)
        context.insert(schedule)
        context.insert(WeekdayHabitResult(day: previousWednesday, weekdayHabit: schedule, status: .done))
        try context.save()

        schedule.weekday = .friday
        try context.save()

        let interval = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: previousWeekStart))
        let digests = try #require(
            WeekdayDigestService(modelContainerService: modelContainerService)
                .fetchWeekdayDigests(for: interval)
        )
        let wednesday = try #require(digests.first(where: { $0.weekday == .wednesday }))
        let friday = try #require(digests.first(where: { $0.weekday == .friday }))

        #expect(wednesday.habits == [schedule])
        #expect(wednesday.results.count == 1)
        #expect(friday.habits.contains(schedule) == false)
    }

    @Test
    func reloadsWeeklySummaryAfterStatusChange() async throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let now = Date.now
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.current.rawValue,
            habit: habit
        )
        schedule.createdAt = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now) ?? now

        context.insert(habit)
        context.insert(schedule)
        try context.save()

        let viewModel = WeeklySummaryViewModel(modelContainerService: modelContainerService)
        await viewModel.loadAvailableWeeks()
        let currentWeekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: now)?.start)
        let currentInterval = try #require(
            viewModel.availableWeeks.first(where: {
                Calendar.current.isDate($0.start, inSameDayAs: currentWeekStart)
            })
        )

        #expect(viewModel.entries(for: currentInterval).first(where: { $0.isCurrentDay })?.completedCount == 0)
        #expect(viewModel.overallScore.completedCount == 0)

        context.insert(WeekdayHabitResult(day: now, weekdayHabit: schedule, status: .done))
        try context.save()
        viewModel.reloadDigests(forWeekStartingAt: currentWeekStart)
        await viewModel.reloadHistoryOverview()

        #expect(viewModel.entries(for: currentInterval).first(where: { $0.isCurrentDay })?.completedCount == 1)
        #expect(viewModel.overallScore.completedCount == 1)
    }

    @Test
    func resolvesStoredNoneResultWithoutCreatingDuplicate() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let currentWeekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let previousWeekStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)
        )
        let previousMonday = try #require(date(for: .monday, inWeekStartingAt: previousWeekStart))
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.monday.rawValue,
            habit: habit
        )
        schedule.createdAt = previousMonday
        let result = WeekdayHabitResult(day: previousMonday, weekdayHabit: schedule, status: .none)

        context.insert(habit)
        context.insert(schedule)
        context.insert(result)
        try context.save()

        let resolvedCount = try TodayTaskReviewService(modelContainerService: modelContainerService)
            .resolvePastUndefinedTasks(referenceDate: currentWeekStart)
        let results = try context.fetch(FetchDescriptor<WeekdayHabitResult>())

        #expect(resolvedCount == 1)
        #expect(results.count == 1)
        #expect(results.first?.status == .failed)
    }

    @Test
    func resolvesEveryStoredNoneResultForSameLocalDay() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let currentWeekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let previousWeekStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)
        )
        let previousMonday = try #require(date(for: .monday, inWeekStartingAt: previousWeekStart))
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.monday.rawValue,
            habit: habit
        )
        schedule.createdAt = previousMonday
        let firstResult = WeekdayHabitResult(day: previousMonday, weekdayHabit: schedule, status: .none)
        let secondResult = WeekdayHabitResult(day: previousMonday, weekdayHabit: schedule, status: .none)
        secondResult.day = try #require(Calendar.current.date(byAdding: .hour, value: 1, to: previousMonday))

        context.insert(habit)
        context.insert(schedule)
        context.insert(firstResult)
        context.insert(secondResult)
        try context.save()

        let resolvedCount = try TodayTaskReviewService(modelContainerService: modelContainerService)
            .resolvePastUndefinedTasks(referenceDate: currentWeekStart)
        let results = try context.fetch(FetchDescriptor<WeekdayHabitResult>())

        #expect(resolvedCount == 1)
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.status == .failed })
    }

    @Test
    func usesReferenceDateForPendingReviewWeekday() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let weekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let monday = try #require(date(for: .monday, inWeekStartingAt: weekStart))
        let tuesday = try #require(Calendar.current.date(byAdding: .day, value: 1, to: monday))
        let referenceDate = try #require(
            Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: monday)
        )
        let habit = Habit(title: "Training")
        let mondaySchedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.monday.rawValue,
            habit: habit
        )
        let tuesdaySchedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.tuesday.rawValue,
            habit: habit
        )
        mondaySchedule.createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: monday)
        )
        tuesdaySchedule.createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: tuesday)
        )

        context.insert(habit)
        context.insert(mondaySchedule)
        context.insert(tuesdaySchedule)
        try context.save()

        let entries = TodayTaskReviewService(modelContainerService: modelContainerService)
            .fetchPendingReviewEntries(referenceDate: referenceDate)

        #expect(entries.map(\.habit) == [mondaySchedule])
    }

    @Test
    func allowsReaddingDeletedTaskWithSameSchedule() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let habit = Habit(title: "Training")
        let deletedSchedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.monday.rawValue,
            habit: habit
        )
        deletedSchedule.deletedAt = .now

        context.insert(habit)
        context.insert(deletedSchedule)
        try context.save()

        try WeeklyTaskService(modelContainerService: modelContainerService).save(
            title: "Training",
            weekday: .monday,
            hour: 8,
            minute: 0
        )

        let schedules = try context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(schedules.count == 2)
        #expect(schedules.filter { !$0.isDeleted }.count == 1)
    }

    @Test
    func groupsFailedTasksAsFinished() throws {
        let modelContainerService = try makeModelContainerService()
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.current.rawValue,
            habit: habit
        )
        let result = WeekdayHabitResult(day: .now, weekdayHabit: schedule, status: .failed)
        let digest = WeekdayDigest(
            weekday: .current,
            habits: [schedule],
            results: [result]
        )
        let viewModel = TodayTasksViewModel()

        modelContainerService.context.insert(habit)
        modelContainerService.context.insert(schedule)
        modelContainerService.context.insert(result)
        try modelContainerService.context.save()
        viewModel.map(todayDigest: digest)

        #expect(viewModel.finishedEntries.map(\.habit) == [schedule])
        #expect(viewModel.todoEntries.isEmpty)
    }

    @Test
    func calculatesWeekdayOffsetFromActualCalendarWeekStart() {
        #expect(Weekday.monday.dayOffset(from: .sunday) == 1)
        #expect(Weekday.sunday.dayOffset(from: .monday) == 6)
    }

    @Test
    func keepsScheduledHistoryBeforeTaskDeletion() throws {
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let currentWeekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let previousWeekStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)
        )
        let previousMonday = try #require(date(for: .monday, inWeekStartingAt: previousWeekStart))
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.monday.rawValue,
            habit: habit
        )
        schedule.createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: previousMonday)
        )
        schedule.deletedAt = .now

        context.insert(habit)
        context.insert(schedule)
        try context.save()

        let interval = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: previousMonday))
        let monday = WeekdayDigestService(modelContainerService: modelContainerService)
            .fetchWeekdayDigests(for: interval)?
            .first(where: { $0.weekday == .monday })

        #expect(monday?.habits == [schedule])
    }

    @Test
    func doesNotPresentReviewSessionWhileAddingTask() throws {
        let suiteName = "ReviewOnboardingTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let modelContainerService = try makeModelContainerService()
        let context = modelContainerService.context
        let habit = Habit(title: "Training")
        let schedule = WeekdayHabit(
            hour: 0,
            minute: 0,
            weekdayRawValue: Weekday.current.rawValue,
            habit: habit
        )
        schedule.createdAt = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now) ?? .now

        context.insert(habit)
        context.insert(schedule)
        try context.save()

        let viewModel = TimetableKingAppViewModel(
            modelContainerService: modelContainerService,
            widgetSnapshotService: TimetableKingTestsWidgetSnapshotService(),
            onboardingStore: OnboardingStore(userDefaults: defaults)
        )
        viewModel.isAddingWeeklyTask = true
        viewModel.refreshForActivation()

        #expect(viewModel.presentedReviewSession == nil)

        viewModel.isAddingWeeklyTask = false
        viewModel.refreshForActivation()

        #expect(viewModel.presentedReviewSession?.entries.count == 1)
    }

    private func makeModelContainerService() throws -> ModelContainerService {
        let schema = Schema([
            Habit.self,
            WeekdayHabit.self,
            WeekdayHabitResult.self,
            HistoryState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContainerService(container: container)
    }

    private func date(for weekday: Weekday, inWeekStartingAt weekStart: Date) -> Date? {
        Calendar.current.date(
            byAdding: .day,
            value: weekday.dayOffset(from: Weekday(date: weekStart)),
            to: weekStart
        )
    }
}

@MainActor
private final class TimetableKingTestsWidgetSnapshotService: WidgetSnapshotSyncing {
    func sync(
        _ dashboardSnapshot: DashboardSnapshot,
        recurringDigests: [WeekdayDigest],
        referenceDate: Date
    ) { }
}
