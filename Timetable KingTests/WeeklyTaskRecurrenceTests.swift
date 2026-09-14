import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct WeeklyTaskRecurrenceTests {
    @Test
    func savesTaskForEverySelectedWeekday() throws {
        let service = try makeModelContainerService()
        let selectedWeekdays: Set<Weekday> = [.monday, .wednesday, .friday]

        try WeeklyTaskService(modelContainerService: service).save(
            title: "Training",
            weekdays: selectedWeekdays,
            hour: 18,
            minute: 30
        )

        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(schedules.count == selectedWeekdays.count)
        #expect(Set(schedules.map(\.weekday)) == selectedWeekdays)
        #expect(Set(schedules.map(\.habit.title)) == ["Training"])
        #expect(schedules.allSatisfy { $0.hour == 18 && $0.minute == 30 })
        #expect(Set(schedules.compactMap(\.recurrenceID)).count == 1)
    }

    @Test
    func rejectsBatchWhenOneSelectedScheduleAlreadyExists() throws {
        let service = try makeModelContainerService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Training", weekday: .monday, hour: 18, minute: 0)

        var didThrow = false
        do {
            try taskService.save(
                title: "Training",
                weekdays: [.monday, .wednesday],
                hour: 18,
                minute: 0
            )
        } catch {
            didThrow = true
            service.context.rollback()
        }

        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(didThrow)
        #expect(schedules.count == 1)
        #expect(schedules.first?.weekday == .monday)
    }

    @Test
    func requiresTitleAndAtLeastOneWeekday() {
        let viewModel = AddWeeklyTaskViewModel()
        viewModel.title = "Read"
        viewModel.weekdays = []

        #expect(!viewModel.isSaveable)

        viewModel.weekdays = [.tuesday, .thursday]

        #expect(viewModel.isSaveable)
    }

    @Test
    func editingRecurrencePreservesHistoricalDaysAndValues() throws {
        let service = try makeModelContainerService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(
            title: "Training",
            weekdays: [.monday, .wednesday],
            hour: 18,
            minute: 0
        )

        let currentWeek = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now))
        let previousWeekStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek.start)
        )
        let createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: previousWeekStart)
        )
        let previousMonday = try #require(date(for: .monday, inWeekStartingAt: previousWeekStart))
        let previousWednesday = try #require(date(for: .wednesday, inWeekStartingAt: previousWeekStart))
        let originalSchedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        for schedule in originalSchedules {
            schedule.createdAt = createdAt
            let day = schedule.weekday == .monday ? previousMonday : previousWednesday
            service.context.insert(
                WeekdayHabitResult(day: day, weekdayHabit: schedule, status: .done)
            )
        }
        try service.context.save()

        try taskService.update(
            habit: try #require(originalSchedules.first),
            title: "Evening training",
            weekdays: [.tuesday, .thursday],
            hour: 19,
            minute: 30
        )

        let allSchedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        let activeSchedules = allSchedules.filter { !$0.isDeleted }
        let historicalSchedules = allSchedules.filter(\.isDeleted)
        #expect(activeSchedules.count == 2)
        #expect(Set(activeSchedules.map(\.weekday)) == [.tuesday, .thursday])
        #expect(activeSchedules.allSatisfy {
            $0.habit.title == "Evening training" && $0.hour == 19 && $0.minute == 30
        })
        #expect(historicalSchedules.count == 2)
        #expect(Set(historicalSchedules.map(\.weekday)) == [.monday, .wednesday])
        #expect(historicalSchedules.allSatisfy {
            $0.habit.title == "Training" && $0.hour == 18 && $0.minute == 0
        })

        let previousWeek = try #require(
            WeekdayDigestService(modelContainerService: service)
                .fetchWeekdayDigests(for: DateInterval(start: previousWeekStart, end: currentWeek.start))
        )
        #expect(previousWeek.first { $0.weekday == .monday }?.results.count == 1)
        #expect(previousWeek.first { $0.weekday == .wednesday }?.results.count == 1)
        #expect(previousWeek.first { $0.weekday == .tuesday }?.isEmpty == true)
        #expect(previousWeek.first { $0.weekday == .thursday }?.isEmpty == true)
    }

    @Test
    func deletingRecurrencePreservesScheduledHistoryWithoutResults() throws {
        let service = try makeModelContainerService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(
            title: "Read",
            weekdays: [.monday, .friday],
            hour: 20,
            minute: 0
        )

        let currentWeek = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now))
        let previousWeekStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek.start)
        )
        let createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: previousWeekStart)
        )
        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        schedules.forEach { $0.createdAt = createdAt }
        try service.context.save()

        try taskService.delete(habit: try #require(schedules.first))

        let deletedSchedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(deletedSchedules.count == 2)
        #expect(deletedSchedules.allSatisfy { $0.isDeleted })

        let previousWeek = try #require(
            WeekdayDigestService(modelContainerService: service)
                .fetchWeekdayDigests(for: DateInterval(start: previousWeekStart, end: currentWeek.start))
        )
        #expect(previousWeek.first { $0.weekday == .monday }?.habits.count == 1)
        #expect(previousWeek.first { $0.weekday == .friday }?.habits.count == 1)
    }

    @Test
    func editingCompletedTaskDoesNotCreateSecondOccurrenceToday() throws {
        let service = try makeModelContainerService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Read", weekday: .current, hour: 8, minute: 0)

        let schedule = try #require(service.context.fetch(FetchDescriptor<WeekdayHabit>()).first)
        schedule.createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now)
        )
        service.context.insert(
            WeekdayHabitResult(day: .now, weekdayHabit: schedule, status: .done)
        )
        try service.context.save()

        try taskService.update(
            habit: schedule,
            title: "Read a book",
            weekdays: [.current],
            hour: 9,
            minute: 0
        )

        let today = try #require(
            WeekdayDigestService(modelContainerService: service)
                .fetchWeekdayDigests()?
                .first { $0.weekday == .current }
        )
        #expect(today.habits.count == 1)
        #expect(today.results.count == 1)
        #expect(today.habits.first?.habit.title == "Read")
        #expect(today.futureHabits.first?.habit.title == "Read a book")
    }

    @Test
    func editingOverdueTaskPreservesTodaysOccurrence() throws {
        let service = try makeModelContainerService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        let referenceDate = try #require(makeReferenceDate(hour: 10))
        let weekday = Weekday(date: referenceDate)
        try taskService.save(title: "Read", weekday: weekday, hour: 8, minute: 0)

        let originalSchedule = try #require(
            service.context.fetch(FetchDescriptor<WeekdayHabit>()).first
        )
        originalSchedule.createdAt = try #require(makeReferenceDate(hour: 7))
        try service.context.save()

        try taskService.update(
            habit: originalSchedule,
            title: "Read a book",
            weekdays: [weekday],
            hour: 9,
            minute: 0,
            at: referenceDate
        )

        let weekInterval = try #require(
            Calendar.current.dateInterval(of: .weekOfYear, for: referenceDate)
        )
        let today = try #require(
            WeekdayDigestService(modelContainerService: service)
                .fetchWeekdayDigests(for: weekInterval)?
                .first { $0.weekday == weekday }
        )
        #expect(today.habits.map(\.habit.title) == ["Read"])
        #expect(today.futureHabits.map(\.habit.title) == ["Read a book"])

        let pendingReview = TodayTaskReviewService(modelContainerService: service)
            .fetchPendingReviewEntries(referenceDate: referenceDate)
        #expect(pendingReview.map(\.habit.habit.title) == ["Read"])
    }

    @Test
    func deletingOverdueTaskPreservesTodaysOccurrence() throws {
        let service = try makeModelContainerService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        let referenceDate = try #require(makeReferenceDate(hour: 10))
        let weekday = Weekday(date: referenceDate)
        try taskService.save(title: "Read", weekday: weekday, hour: 8, minute: 0)

        let schedule = try #require(
            service.context.fetch(FetchDescriptor<WeekdayHabit>()).first
        )
        schedule.createdAt = try #require(makeReferenceDate(hour: 7))
        try service.context.save()

        try taskService.delete(habit: schedule, at: referenceDate)

        let weekInterval = try #require(
            Calendar.current.dateInterval(of: .weekOfYear, for: referenceDate)
        )
        let today = try #require(
            WeekdayDigestService(modelContainerService: service)
                .fetchWeekdayDigests(for: weekInterval)?
                .first { $0.weekday == weekday }
        )
        #expect(today.habits.map(\.habit.title) == ["Read"])

        let reviewService = TodayTaskReviewService(modelContainerService: service)
        #expect(reviewService.fetchPendingReviewEntries(referenceDate: referenceDate).count == 1)

        let nextDay = try #require(
            Calendar.current.date(byAdding: .day, value: 1, to: referenceDate)
        )
        #expect(try reviewService.resolvePastUndefinedTasks(referenceDate: nextDay) == 1)
        let result = try #require(
            service.context.fetch(FetchDescriptor<WeekdayHabitResult>()).first
        )
        #expect(result.status == .failed)
        #expect(Calendar.current.isDate(result.day, inSameDayAs: referenceDate))
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

    private func makeReferenceDate(hour: Int) -> Date? {
        Calendar.current.date(
            from: DateComponents(
                year: 2026,
                month: 9,
                day: 14,
                hour: hour
            )
        )
    }
}
