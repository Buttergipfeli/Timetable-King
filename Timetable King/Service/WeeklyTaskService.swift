import Foundation
import SwiftData

final class WeeklyTaskService {
    private let modelContainerService: ModelContainerService
    private let historyStateService: HistoryStateService

    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
        historyStateService = HistoryStateService(modelContainerService: modelContainerService)
    }

    func delete(habit: WeekdayHabit) throws {
        let context = modelContainerService.context
        if habit.results.isEmpty {
            context.delete(habit)
        } else {
            habit.deletedAt = .now
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
        let context = modelContainerService.context
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.title == title })
        let updatedHabit: Habit
        if let existing = try context.fetch(descriptor).first {
            updatedHabit = existing
        } else {
            updatedHabit = Habit(title: title)
            context.insert(updatedHabit)
        }

        guard try hasDuplicate(
            habit: updatedHabit,
            weekday: weekday,
            hour: hour,
            minute: minute,
            excluding: habit
        ).not else {
            throw WeeklyTaskServiceError.duplicateTask
        }

        habit.habit = updatedHabit
        habit.weekday = weekday
        habit.hour = hour
        habit.minute = minute
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

        for weekday in weekdays.sorted(using: KeyPathComparator(\.sortIndex)) {
            context.insert(
                WeekdayHabit(
                    hour: hour,
                    minute: minute,
                    weekdayRawValue: weekday.rawValue,
                    habit: habit
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
        excluding excludedSchedule: WeekdayHabit? = nil
    ) throws -> Bool {
        try modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()).contains {
            !$0.isDeleted &&
            $0 != excludedSchedule &&
            $0.habit == habit &&
            $0.weekday == weekday &&
            $0.hour == hour &&
            $0.minute == minute
        }
    }
}

private enum WeeklyTaskServiceError: Error {
    case duplicateTask
    case missingWeekday
}
