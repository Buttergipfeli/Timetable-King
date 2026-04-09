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
            habit.isDeleted = true
        }
        try context.save()
    }

    func deleteHistory() throws {
        let context = modelContainerService.context
        let results = try context.fetch(FetchDescriptor<WeekdayHabitResult>())
        results.forEach { context.delete($0) }
        let descriptor = FetchDescriptor<WeekdayHabit>(
            predicate: #Predicate { $0.isDeleted == true }
        )
        let softDeleted = try context.fetch(descriptor)
        softDeleted.forEach { context.delete($0) }
        try context.save()
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
        habit.habit = updatedHabit
        habit.weekday = weekday
        habit.hour = hour
        habit.minute = minute
        try context.save()
    }

    func save(title: String, weekday: Weekday, hour: Int, minute: Int) throws {
        let context = modelContainerService.context
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.title == title })
        let habit: Habit
        if let existing = try context.fetch(descriptor).first {
            habit = existing
        } else {
            habit = Habit(title: title)
            context.insert(habit)
        }
        context.insert(WeekdayHabit(hour: hour, minute: minute, weekdayRawValue: weekday.rawValue, habit: habit))
        try context.save()
    }
}
