import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let modelContainerService: ModelContainerService
    
    private(set) var weekdayHabits: [WeekdayHabit] = []
    private(set) var results: [WeekdayHabitResult] = []
    
    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
        load()
    }

    func load() {
        loadWeekdayHabits()
        fetchAllResultsForCurrentWeek()
    }

    private func fetchAllResultsForCurrentWeek() {
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
    
    private func loadWeekdayHabits() {
        guard let fetchedWeekdayHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()) else { return }
        weekdayHabits = fetchedWeekdayHabits
    }
}
