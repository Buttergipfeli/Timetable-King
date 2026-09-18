import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct TaskReminderDeliveryTests {
    @Test
    func resolvingOneTaskKeepsOtherDeliveredReminders() throws {
        let container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true)
        let first = makeSchedule(title: "Read")
        let second = makeSchedule(title: "Walk")
        container.mainContext.insert(first)
        container.mainContext.insert(second)
        let date = Date.now
        container.mainContext.insert(WeekdayHabitResult(day: date, weekdayHabit: first, status: .skipped))
        try container.mainContext.save()

        let state = TaskReminderDeliveryState(schedules: [first, second])

        #expect(!state.contains(userInfo: payload(for: first, on: date)))
        #expect(state.contains(userInfo: payload(for: second, on: date)))
    }

    @Test
    func removesDeliveredRemindersForDisabledDeletedAndMissingSchedules() {
        let schedule = makeSchedule(title: "Read")
        let date = Date.now
        let userInfo = payload(for: schedule, on: date)
        #expect(TaskReminderDeliveryState(schedules: [schedule]).contains(userInfo: userInfo))

        schedule.reminder = .off
        #expect(!TaskReminderDeliveryState(schedules: [schedule]).contains(userInfo: userInfo))
        schedule.reminder = .atTime
        schedule.deletedAt = date
        #expect(!TaskReminderDeliveryState(schedules: [schedule]).contains(userInfo: userInfo))
        #expect(!TaskReminderDeliveryState(schedules: []).contains(userInfo: userInfo))
    }

    @Test
    func preservesDueOccurrenceButRejectsOccurrencesOutsideScheduleLifetime() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
        let schedule = makeSchedule(title: "Read")
        schedule.deletedAt = tomorrow
        let oldState = TaskReminderDeliveryState(schedules: [schedule])
        #expect(oldState.contains(userInfo: payload(for: schedule, on: today)))
        #expect(!oldState.contains(userInfo: payload(for: schedule, on: tomorrow)))

        schedule.deletedAt = nil
        schedule.createdAt = tomorrow
        let futureState = TaskReminderDeliveryState(schedules: [schedule])
        #expect(!futureState.contains(userInfo: payload(for: schedule, on: today)))
        #expect(futureState.contains(userInfo: payload(for: schedule, on: tomorrow)))
    }

    @Test
    func deliveredStateIsIndependentOfLaterModelChanges() {
        let schedule = makeSchedule(title: "Read")
        let date = Date.now
        let state = TaskReminderDeliveryState(schedules: [schedule])
        schedule.reminder = .off

        #expect(state.contains(userInfo: payload(for: schedule, on: date)))
        #expect(!TaskReminderDeliveryState(schedules: [schedule]).contains(userInfo: payload(for: schedule, on: date)))
    }

    @Test
    func plannedPayloadIncludesTheOccurrenceAndSupportsDeliveryValidation() throws {
        let schedule = makeSchedule(title: "Read")
        let reminder = try #require(TaskReminderPlanner().plan(schedules: [schedule]).first)

        #expect(reminder.notificationUserInfo["taskDate"] as? TimeInterval == reminder.taskDate.timeIntervalSince1970)
        #expect(reminder.notificationUserInfo["taskURL"] as? String == reminder.taskURL.absoluteString)
        #expect(TaskReminderDeliveryState(schedules: [schedule]).contains(userInfo: reminder.notificationUserInfo))
    }

    @Test
    func reminderLinksPreserveOccurrenceIdentity() throws {
        let scheduleID = UUID()
        let taskDate = Date(timeIntervalSince1970: 1_790_000_000)
        let url = TimetableDeepLink.reminderURL(scheduleID: scheduleID, taskDate: taskDate)
        #expect(TimetableDeepLink.destination(for: url) == .reminder(scheduleID: scheduleID, taskDate: taskDate))
        #expect(TimetableDeepLink.destination(for: try #require(URL(string: "timetableking://reminder"))) == nil)
        #expect(TimetableDeepLink.destination(for: try #require(URL(
            string: "timetableking://reminder?schedule=\(scheduleID.uuidString)&date=nan"
        ))) == nil)
    }

    @Test
    func reminderOpensExactScheduleAndNeverAnotherOccurrence() throws {
        let service = ModelContainerService(container: Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true))
        let first = makeSchedule(title: "Read")
        let second = makeSchedule(title: "Read")
        service.context.insert(first)
        service.context.insert(second)
        try service.context.save()
        let suiteName = "TaskReminderDeliveryTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let app = TimetableKingAppViewModel(
            modelContainerService: service,
            widgetSnapshotService: WidgetSnapshotService(store: TimetableWidgetSnapshotStore(userDefaults: defaults)),
            onboardingStore: OnboardingStore(userDefaults: defaults)
        )
        let calendar = Calendar.current
        let today = Date.now
        let lastWeek = try #require(calendar.date(byAdding: .day, value: -7, to: today))
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
        let id = try #require(second.reminderID)

        app.open(url: TimetableDeepLink.reminderURL(scheduleID: id, taskDate: today))
        #expect(app.presentedEntry?.habit == second)

        for date in [lastWeek, tomorrow] {
            app.open(url: TimetableDeepLink.reminderURL(scheduleID: id, taskDate: date))
            #expect(app.presentedEntry == nil)
            #expect(app.presentedCard == .todayTasks)
        }

        app.open(url: TimetableDeepLink.reminderURL(scheduleID: UUID(), taskDate: today))
        #expect(app.presentedEntry == nil)
        #expect(app.presentedCard == .todayTasks)
    }

    private func makeSchedule(title: String) -> WeekdayHabit {
        let schedule = WeekdayHabit(
            hour: 8, minute: 0, weekdayRawValue: Weekday.current.rawValue,
            habit: Habit(title: title), reminder: .atTime
        )
        schedule.createdAt = .distantPast
        return schedule
    }

    private func payload(for schedule: WeekdayHabit, on date: Date) -> [AnyHashable: Any] {
        ["scheduleID": schedule.reminderID!.uuidString, "taskDate": date.timeIntervalSince1970]
    }
}
