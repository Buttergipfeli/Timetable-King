import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let modelContainerService: ModelContainerService
    
    private(set) var weekdayHabits: [WeekdayHabit] = []
    private(set) var resultsByWeekday: [WeekdayHabitResultsByWeekday] = []
    
    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
    }

    func load() {
        loadWeekdayHabits()
        fetchAllResultsForCurrentWeekByWeekday()
    }

    private func fetchAllResultsForCurrentWeekByWeekday() {
        guard let fetchedResultsForCurrentWeek = fetchWeekdayHabitResultsForCurrentWeek() else { return }
        resultsByWeekday = fetchedResultsForCurrentWeek
            .sorted(using: WeekdayHabitResultComparator())
            .reduce([WeekdayHabitResultsByWeekday]()) { resultsByWeekday, result in
                var newResultsByWeekday = resultsByWeekday
                let previousResult = resultsByWeekday.last
                
                if previousResult?.weekday == result.weekdayHabit.weekday {
                    let resultsForWeekday = newResultsByWeekday[newResultsByWeekday.count - 1]
                    newResultsByWeekday[newResultsByWeekday.count - 1] = WeekdayHabitResultsByWeekday(
                        weekday: result.weekdayHabit.weekday,
                        results: resultsForWeekday.results + [result]
                    )
                    
                    return newResultsByWeekday
                } else {
                    newResultsByWeekday.append(WeekdayHabitResultsByWeekday(
                        weekday: result.weekdayHabit.weekday,
                        results: [result]
                    ))
                    
                    return newResultsByWeekday
                }
            }
    }
    
    private func loadWeekdayHabits() {
        guard let fetchedWeekdayHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()) else { return }
        weekdayHabits = fetchedWeekdayHabits
    }
    
    private func fetchWeekdayHabitResultsForCurrentWeek() -> [WeekdayHabitResult]? {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return nil }
        let weekStart = weekInterval.start
        let nextWeekStart = weekInterval.end
        
        let descriptor = FetchDescriptor<WeekdayHabitResult>(
            predicate: #Predicate<WeekdayHabitResult> { result in
                result.day >= weekStart && result.day < nextWeekStart
            }
        )
        
        return try? modelContainerService.context.fetch(descriptor)
    }
}
