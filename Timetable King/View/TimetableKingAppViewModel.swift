import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let modelContainerService: ModelContainerService
    
    private(set) var habitablesForWeekdays = [PairedWeekdayHabitablesByWeekday]()
    
    var nonEmptyHabitablesForWeekdays: [PairedWeekdayHabitablesByWeekday] {
        habitablesForWeekdays.filter(\.habits.isEmpty.not)
    }
    
    var todayHabits: [WeekdayHabit] {
        habitablesForWeekdays.first(where: \.weekday.isToday)?.habits ?? []
    }
    
    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
    }

    func load() {
        guard let fetchedWeekdayHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()),
        let fetchWeekdayHabitResults = fetchWeekdayHabitResultsForCurrentWeek() else { return }
        
        let weekdayHabitablesByWeekdayForHabits = convertHabitableForCurrentWeekToHabitableByWeekday(weekdayHabitables: fetchedWeekdayHabits)
        let weekdayHabitablesByWeekdayForResults = convertHabitableForCurrentWeekToHabitableByWeekday(weekdayHabitables: fetchWeekdayHabitResults)
        
        habitablesForWeekdays = PairedWeekdayHabitablesByWeekdays(
            habits: weekdayHabitablesByWeekdayForHabits,
            results: weekdayHabitablesByWeekdayForResults
        ).zipSortedByWeekdays()
    }

    private func convertHabitableForCurrentWeekToHabitableByWeekday<Habitable: WeekdayHabitable>(
        weekdayHabitables: [Habitable]
    ) -> [WeekdayHabitablesByWeekday<Habitable>] {
        weekdayHabitables
            .sorted(using: WeekdayHabitableComparator())
            .reduce([WeekdayHabitablesByWeekday]()) { habitablesByWeekday, habitable in
                var newHabitablesByWeekday = habitablesByWeekday
                let previousHabit = habitablesByWeekday.last
                
                if previousHabit?.weekday == habitable.weekdayHabit.weekday {
                    let weekdayHabitablesForWeekday = newHabitablesByWeekday[newHabitablesByWeekday.count - 1]
                    newHabitablesByWeekday[newHabitablesByWeekday.count - 1] = weekdayHabitablesForWeekday.appending(habitable)
                } else {
                    let weekdayHabitablesForWeekday = WeekdayHabitablesByWeekday(weekday: habitable.weekdayHabit.weekday, habitables: [habitable])
                    newHabitablesByWeekday.append(weekdayHabitablesForWeekday)
                }
                
                return newHabitablesByWeekday
            }
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
