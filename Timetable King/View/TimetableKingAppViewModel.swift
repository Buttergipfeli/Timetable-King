import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let modelContainerService: ModelContainerService
    
    private(set) var results: [WeekdayHabitResult] = []
    private(set) var habits: [WeekdayHabit] = []
    
    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
        load()
    }

    func load() {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return }
        let weekStart = weekInterval.start
        let nextWeekStart = weekInterval.end
        
        let descriptor = FetchDescriptor<WeekdayHabitResult>(
            predicate: #Predicate<WeekdayHabitResult> { result in
                result.day >= weekStart && result.day < nextWeekStart
            }
        )
        
        guard let fetchedResults = try? modelContainerService.context.fetch(descriptor) else { return }
        
        results = fetchedResults.sorted { lhs, rhs in
            if lhs.day != rhs.day {
                return lhs.day < rhs.day
            }
            if lhs.weekdayHabit.hour != rhs.weekdayHabit.hour {
                return lhs.weekdayHabit.hour < rhs.weekdayHabit.hour
            }
            if lhs.weekdayHabit.minute != rhs.weekdayHabit.minute {
                return lhs.weekdayHabit.minute < rhs.weekdayHabit.minute
            }
            return lhs.weekdayHabit.habit.title < rhs.weekdayHabit.habit.title
        }
    }
    
    private func loadHabits() {
        guard let fetchedHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()) else { return }
        habits = fetchedHabits
    }
}
