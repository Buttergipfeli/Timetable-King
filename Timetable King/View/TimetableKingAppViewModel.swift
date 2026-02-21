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
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return }
        let weekStart = weekInterval.start
        let nextWeekStart = weekInterval.end
        
        let descriptor = FetchDescriptor<WeekdayHabitResult>(
            predicate: #Predicate<WeekdayHabitResult> { result in
                result.day >= weekStart && result.day < nextWeekStart
            }
        )
        
        guard let fetchedResults = try? modelContainerService.context.fetch(descriptor) else { return }
        results = fetchedResults.sorted(using: WeekdayHabitResultComparator())
    }
    
    private func loadHabits() {
        guard let fetchedHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()) else { return }
        habits = fetchedHabits
    }
}
