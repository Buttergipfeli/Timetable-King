import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct TaskReminderTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Zurich")!
        return calendar
    }

    @Test
    func reminderBeforeMidnightBelongsToNextDaysTask() throws {
        let task = schedule(weekday: .monday, hour: 0, minute: 5, reminder: .tenMinutesBefore)
        let reference = try date(day: 13, hour: 23, minute: 50)
        let reminders = TaskReminderPlanner().plan(schedules: [task], referenceDate: reference, calendar: calendar)

        let first = try #require(reminders.first)
        #expect(first.taskDate == (try date(day: 14, hour: 0, minute: 5)))
        #expect(first.fireDate == (try date(day: 13, hour: 23, minute: 55)))
        #expect(TimetableDeepLink.destination(for: first.taskURL) != nil)
    }

    @Test
    func excludesResolvedOccurrencesWithoutLosingFollowingWeeks() throws {
        let service = makeService()
        let task = schedule(weekday: .monday, hour: 10, reminder: .atTime)
        service.context.insert(task)
        service.context.insert(WeekdayHabitResult(day: try date(day: 14), weekdayHabit: task, status: .done))
        try service.context.save()
        let reference = try date(day: 14, hour: 8)
        let reminders = TaskReminderPlanner().plan(schedules: [task], referenceDate: reference, calendar: calendar)

        #expect(reminders.first?.taskDate == (try date(day: 21, hour: 10)))
        task.results.first?.status = .none
        #expect(TaskReminderPlanner().plan(schedules: [task], referenceDate: reference, calendar: calendar)
            .first?.taskDate == (try date(day: 14, hour: 10)))
    }

    @Test
    func disablesRemindersAndExcludesDeletedVersions() throws {
        let task = schedule(weekday: .monday, hour: 10, reminder: .atTime)
        let reference = try date(day: 14, hour: 8)
        task.deletedAt = try date(day: 14)
        #expect(TaskReminderPlanner().plan(schedules: [task], referenceDate: reference, calendar: calendar).isEmpty)

        task.deletedAt = nil
        task.reminder = .off
        #expect(TaskReminderPlanner().plan(schedules: [task], referenceDate: reference, calendar: calendar).isEmpty)
    }

    @Test
    func futureVersionDoesNotCreateTodaysReminder() throws {
        let task = schedule(weekday: .monday, hour: 10, reminder: .atTime)
        task.createdAt = try date(day: 15)
        let reminders = TaskReminderPlanner().plan(
            schedules: [task], referenceDate: try date(day: 14, hour: 8), calendar: calendar
        )
        #expect(reminders.first?.taskDate == (try date(day: 21, hour: 10)))
    }

    @Test
    func limitsPendingRemindersToEarliestOccurrencesAcrossTasks() throws {
        let tasks = Weekday.allCases.map { schedule(weekday: $0, hour: 10, reminder: .atTime) }
        let reference = try date(day: 14, hour: 8)
        let reminders = TaskReminderPlanner().plan(schedules: tasks, referenceDate: reference, calendar: calendar)

        #expect(reminders.count == 64)
        #expect(Set(reminders.map(\.id)).count == 64)
        #expect(reminders.map(\.fireDate) == reminders.map(\.fireDate).sorted())
        #expect(reminders.first?.taskDate == (try date(day: 14, hour: 10)))
        #expect(reminders.last?.taskDate == calendar.date(byAdding: .day, value: 63, to: try date(day: 14, hour: 10)))
    }

    @Test
    func keepsLocalTimeAcrossDaylightSavingChange() throws {
        let task = schedule(weekday: .monday, hour: 8, reminder: .tenMinutesBefore)
        let reference = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 19)))
        let reminders = TaskReminderPlanner().plan(schedules: [task], referenceDate: reference, calendar: calendar, limit: 2)

        #expect(reminders.count == 2)
        #expect(reminders.allSatisfy { calendar.component(.hour, from: $0.taskDate) == 8 })
        #expect(reminders.allSatisfy { calendar.component(.minute, from: $0.fireDate) == 50 })
        #expect(reminders[1].taskDate.timeIntervalSince(reminders[0].taskDate) == 7 * 86400 + 3600)
    }

    @Test
    func changingOnlyReminderDoesNotVersionOrChangeHistory() throws {
        let service = makeService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Read", weekdays: [.monday, .friday], hour: 8, minute: 0)
        let original = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        let selected = try #require(original.first)
        let createdAt = selected.createdAt
        service.context.insert(WeekdayHabitResult(day: try date(day: 7), weekdayHabit: selected, status: .done))
        try service.context.save()

        try taskService.update(
            habit: selected, title: "Read", weekdays: [.monday, .friday], hour: 8, minute: 0,
            reminder: .tenMinutesBefore
        )

        let persisted = try ModelContext(service.modelContainer).fetch(FetchDescriptor<WeekdayHabit>())
        #expect(persisted.count == 2)
        #expect(persisted.allSatisfy { $0.reminder == .tenMinutesBefore && $0.reminderID != nil && !$0.isDeleted })
        #expect(selected.createdAt == createdAt)
        #expect(selected.results.first?.status == .done)
    }

    @Test
    func editingAndDeletingRecurrenceReplacesPlannedReminders() throws {
        let service = makeService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Read", weekdays: [.monday], hour: 10, minute: 0, reminder: .atTime)
        let original = try #require(service.context.fetch(FetchDescriptor<WeekdayHabit>()).first)
        original.createdAt = .distantPast
        try service.context.save()
        let reference = try date(day: 14, hour: 8)

        try taskService.update(
            habit: original, title: "Book", weekdays: [.tuesday], hour: 11, minute: 0,
            reminder: .tenMinutesBefore, at: reference
        )
        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        let plan = TaskReminderPlanner().plan(schedules: schedules, referenceDate: reference, calendar: calendar)
        #expect(plan.allSatisfy { $0.title == "Book" })
        #expect(plan.first?.fireDate == (try date(day: 15, hour: 10, minute: 50)))

        try taskService.delete(habit: try #require(schedules.first { !$0.isDeleted }), at: reference)
        #expect(TaskReminderPlanner().plan(schedules: schedules, referenceDate: reference, calendar: calendar).isEmpty)
    }

    @Test
    func editingWithoutReminderSelectionPreservesExistingReminder() throws {
        let service = makeService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Read", weekdays: [.monday], hour: 10, minute: 0, reminder: .atTime)
        let original = try #require(service.context.fetch(FetchDescriptor<WeekdayHabit>()).first)

        try taskService.update(habit: original, title: "Book", weekday: .monday, hour: 11, minute: 0)

        let active = try service.context.fetch(FetchDescriptor<WeekdayHabit>()).filter { !$0.isDeleted }
        #expect(active.count == 1)
        #expect(active.first?.reminder == .atTime)
    }

    @Test
    func repeatedEditsDoNotBringFutureVersionBackIntoToday() throws {
        let service = makeService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Read", weekdays: [.monday], hour: 8, minute: 0, reminder: .atTime)
        let original = try #require(service.context.fetch(FetchDescriptor<WeekdayHabit>()).first)
        original.createdAt = .distantPast
        try service.context.save()
        let reference = try date(day: 14, hour: 9)

        try taskService.update(
            habit: original, title: "Read", weekdays: [.monday], hour: 10, minute: 0, at: reference
        )
        let updated = try #require(service.context.fetch(FetchDescriptor<WeekdayHabit>()).first { !$0.isDeleted })
        try taskService.update(
            habit: updated, title: "Book", weekdays: [.monday], hour: 11, minute: 0, at: reference
        )

        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        let newest = try #require(schedules.first { !$0.isDeleted })
        #expect(newest.createdAt == (try date(day: 15)))
        let plan = TaskReminderPlanner().plan(schedules: schedules, referenceDate: reference, calendar: calendar)
        #expect(plan.first?.taskDate == (try date(day: 21, hour: 11)))
    }

    private func schedule(weekday: Weekday, hour: Int, minute: Int = 0, reminder: TaskReminder) -> WeekdayHabit {
        let schedule = WeekdayHabit(
            hour: hour, minute: minute, weekdayRawValue: weekday.rawValue,
            habit: Habit(title: "Read"), reminder: reminder
        )
        schedule.createdAt = .distantPast
        return schedule
    }

    private func date(day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute)))
    }

    private func makeService() -> ModelContainerService {
        ModelContainerService(container: Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true))
    }
}
