import Foundation

struct TaskReminderDeliveryState {
    private struct Schedule {
        let firstDay: Date
        let deletionDay: Date?
        let resolvedDays: Set<Date>
    }

    private let schedules: [UUID: Schedule]
    private let calendar: Calendar

    init(schedules: [WeekdayHabit], calendar: Calendar = .current) {
        self.calendar = calendar
        self.schedules = schedules.reduce(into: [:]) { states, schedule in
            guard schedule.reminder != .off, let id = schedule.reminderID else { return }
            states[id] = Schedule(
                firstDay: calendar.startOfDay(for: schedule.createdAt),
                deletionDay: schedule.deletedAt.map(calendar.startOfDay(for:)),
                resolvedDays: Set(schedule.results.filter { $0.status != .none }.map {
                    calendar.startOfDay(for: $0.day)
                })
            )
        }
    }

    func contains(userInfo: [AnyHashable: Any]) -> Bool {
        guard let idString = userInfo["scheduleID"] as? String,
              let id = UUID(uuidString: idString),
              let schedule = schedules[id],
              let timestamp = userInfo["taskDate"] as? TimeInterval else { return false }

        let day = calendar.startOfDay(for: Date(timeIntervalSince1970: timestamp))
        return day >= schedule.firstDay
            && (schedule.deletionDay.map { day < $0 } ?? true)
            && !schedule.resolvedDays.contains(day)
    }
}
