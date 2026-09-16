import Foundation
import SwiftData

final class WeeklyTaskService {
    private let modelContainerService: ModelContainerService
    private let historyStateService: HistoryStateService

    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
        historyStateService = HistoryStateService(modelContainerService: modelContainerService)
    }

    func delete(habit: WeekdayHabit, at date: Date = .now) throws {
        let context = modelContainerService.context
        let currentSchedules = habit.activeRecurrenceSchedules
        let effectiveDate = effectiveChangeDate(for: currentSchedules, at: date)
        for schedule in currentSchedules {
            schedule.deletedAt = effectiveDate
        }
        try context.save()
    }

    func deleteHistory() throws {
        let context = modelContainerService.context
        let results = try context.fetch(FetchDescriptor<WeekdayHabitResult>())
        results.forEach { context.delete($0) }
        let descriptor = FetchDescriptor<WeekdayHabit>(
            predicate: #Predicate { $0.deletedAt != nil }
        )
        let softDeleted = try context.fetch(descriptor)
        softDeleted.forEach { context.delete($0) }
        try historyStateService.markHistoryDeleted()
    }

    func update(habit: WeekdayHabit, title: String, weekday: Weekday, hour: Int, minute: Int) throws {
        try update(
            habit: habit,
            title: title,
            weekdays: [weekday],
            hour: hour,
            minute: minute
        )
    }

    func update(
        habit: WeekdayHabit,
        title: String,
        weekdays: Set<Weekday>,
        hour: Int,
        minute: Int,
        at date: Date = .now
    ) throws {
        guard !weekdays.isEmpty else {
            throw WeeklyTaskServiceError.missingWeekday
        }

        let currentSchedules = habit.activeRecurrenceSchedules
        guard !currentSchedules.isEmpty else {
            throw WeeklyTaskServiceError.missingTask
        }

        let currentWeekdays = Set(currentSchedules.map(\.weekday))
        let isUnchanged = currentWeekdays == weekdays && currentSchedules.allSatisfy {
            $0.habit.title == title && $0.hour == hour && $0.minute == minute
        }
        guard !isUnchanged else { return }

        let context = modelContainerService.context
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.title == title })
        let updatedHabit: Habit
        if let existing = try context.fetch(descriptor).first {
            updatedHabit = existing
        } else {
            updatedHabit = Habit(title: title)
            context.insert(updatedHabit)
        }

        for weekday in weekdays {
            guard try hasDuplicate(
                habit: updatedHabit,
                weekday: weekday,
                hour: hour,
                minute: minute,
                excluding: currentSchedules
            ).not else {
                throw WeeklyTaskServiceError.duplicateTask
            }
        }

        let effectiveDate = effectiveChangeDate(
            for: currentSchedules,
            newWeekdays: weekdays,
            hour: hour,
            minute: minute,
            at: date
        )
        for schedule in currentSchedules {
            schedule.deletedAt = effectiveDate
        }

        let recurrenceID = habit.recurrenceID ?? UUID()
        for weekday in weekdays.sorted(using: KeyPathComparator(\.sortIndex)) {
            let schedule = WeekdayHabit(
                hour: hour,
                minute: minute,
                weekdayRawValue: weekday.rawValue,
                habit: updatedHabit,
                recurrenceID: recurrenceID
            )
            schedule.createdAt = effectiveDate
            context.insert(schedule)
        }

        try context.save()
    }

    func save(title: String, weekday: Weekday, hour: Int, minute: Int) throws {
        try save(title: title, weekdays: [weekday], hour: hour, minute: minute)
    }

    func save(title: String, weekdays: Set<Weekday>, hour: Int, minute: Int) throws {
        guard !weekdays.isEmpty else {
            throw WeeklyTaskServiceError.missingWeekday
        }

        let context = modelContainerService.context
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.title == title })
        let habit: Habit
        if let existing = try context.fetch(descriptor).first {
            habit = existing
        } else {
            habit = Habit(title: title)
            context.insert(habit)
        }

        for weekday in weekdays {
            guard try hasDuplicate(
                habit: habit,
                weekday: weekday,
                hour: hour,
                minute: minute
            ).not else {
                throw WeeklyTaskServiceError.duplicateTask
            }
        }

        let recurrenceID = UUID()
        for weekday in weekdays.sorted(using: KeyPathComparator(\.sortIndex)) {
            context.insert(
                WeekdayHabit(
                    hour: hour,
                    minute: minute,
                    weekdayRawValue: weekday.rawValue,
                    habit: habit,
                    recurrenceID: recurrenceID
                )
            )
        }
        try context.save()
    }

    private func hasDuplicate(
        habit: Habit,
        weekday: Weekday,
        hour: Int,
        minute: Int,
        excluding excludedSchedules: [WeekdayHabit] = []
    ) throws -> Bool {
        try modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()).contains {
            !$0.isDeleted &&
            !excludedSchedules.contains($0) &&
            $0.habit == habit &&
            $0.weekday == weekday &&
            $0.hour == hour &&
            $0.minute == minute
        }
    }

    private func effectiveChangeDate(
        for schedules: [WeekdayHabit],
        newWeekdays: Set<Weekday> = [],
        hour: Int? = nil,
        minute: Int? = nil,
        at date: Date
    ) -> Date {
        let calendar = Calendar.current
        let currentWeekday = Weekday(date: date)
        let currentOccurrenceHasStarted = schedules.contains { schedule in
            guard schedule.weekday == currentWeekday else { return false }
            let hasResult = schedule.results.contains {
                calendar.isDate($0.day, inSameDayAs: date)
            }
            return hasResult || scheduledDate(
                hour: schedule.hour,
                minute: schedule.minute,
                on: date,
                calendar: calendar
            ) <= date
        }

        let newOccurrenceWouldBeRetroactive: Bool
        if newWeekdays.contains(currentWeekday), let hour, let minute {
            newOccurrenceWouldBeRetroactive = scheduledDate(
                hour: hour,
                minute: minute,
                on: date,
                calendar: calendar
            ) <= date
        } else {
            newOccurrenceWouldBeRetroactive = false
        }

        guard currentOccurrenceHasStarted || newOccurrenceWouldBeRetroactive else { return date }
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date
    }

    private func scheduledDate(
        hour: Int,
        minute: Int,
        on date: Date,
        calendar: Calendar
    ) -> Date {
        calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        ) ?? date
    }
}

private enum WeeklyTaskServiceError: Error {
    case duplicateTask
    case missingWeekday
    case missingTask
}
