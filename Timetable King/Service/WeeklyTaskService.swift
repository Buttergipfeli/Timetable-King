import Foundation
import SwiftData

final class WeeklyTaskService {
    private let modelContainerService: ModelContainerService

    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
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
