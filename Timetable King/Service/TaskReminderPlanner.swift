import Foundation

struct PlannedTaskReminder: Equatable, Identifiable {
    let id: String
    let scheduleID: UUID
    let title: String
    let taskDate: Date
    let fireDate: Date
    let taskURL: URL

    var notificationUserInfo: [AnyHashable: Any] {
        [
            "scheduleID": scheduleID.uuidString,
            "taskDate": taskDate.timeIntervalSince1970,
            "taskURL": taskURL.absoluteString
        ]
    }
}

struct TaskReminderPlanner {
    static let identifierPrefix = "task-reminder."
    static let pendingLimit = 64

    func plan(
        schedules: [WeekdayHabit],
        referenceDate: Date = .now,
        calendar: Calendar = .current,
        limit: Int = Self.pendingLimit
    ) -> [PlannedTaskReminder] {
        guard limit > 0 else { return [] }
        var reminders: [PlannedTaskReminder] = []

        for schedule in schedules {
            guard let minutes = schedule.reminder.minutesBefore,
                  let reminderID = schedule.reminderID else { continue }

            let firstDay = calendar.startOfDay(for: max(referenceDate, schedule.createdAt))
            let weekday = schedule.weekday.sortIndex % 7 + 1
            let dayOffset = (weekday - calendar.component(.weekday, from: firstDay) + 7) % 7
            guard let firstOccurrenceDay = calendar.date(byAdding: .day, value: dayOffset, to: firstDay) else {
                continue
            }
            let resolvedDays = Set(schedule.results.filter { $0.status != .none && $0.day >= firstDay }.map {
                calendar.startOfDay(for: $0.day)
            })

            for weekOffset in 0..<(limit + resolvedDays.count + 1) {
                guard let day = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: firstOccurrenceDay),
                      let taskDate = calendar.date(
                        bySettingHour: schedule.hour, minute: schedule.minute, second: 0, of: day
                      ),
                      let fireDate = calendar.date(byAdding: .minute, value: -minutes, to: taskDate) else {
                    continue
                }
                if let deletedAt = schedule.deletedAt, taskDate >= calendar.startOfDay(for: deletedAt) {
                    break
                }
                guard fireDate > referenceDate,
                      !resolvedDays.contains(calendar.startOfDay(for: taskDate)) else { continue }

                reminders.append(PlannedTaskReminder(
                    id: "\(Self.identifierPrefix)\(reminderID.uuidString).\(Int(taskDate.timeIntervalSince1970))",
                    scheduleID: reminderID,
                    title: schedule.habit.title,
                    taskDate: taskDate,
                    fireDate: fireDate,
                    taskURL: TimetableDeepLink.reminderURL(scheduleID: reminderID, taskDate: taskDate)
                ))
            }
        }

        return Array(reminders.sorted {
            $0.fireDate == $1.fireDate ? $0.id < $1.id : $0.fireDate < $1.fireDate
        }.prefix(limit))
    }
}
