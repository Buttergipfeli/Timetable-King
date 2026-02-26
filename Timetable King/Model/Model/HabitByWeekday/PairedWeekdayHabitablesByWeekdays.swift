struct PairedWeekdayHabitablesByWeekdays {
    let habits: [WeekdayHabitablesByWeekday<WeekdayHabit>]
    let results: [WeekdayHabitablesByWeekday<WeekdayHabitResult>]
    
    func zipSortedByWeekdays() -> [PairedWeekdayHabitablesByWeekday] {
        Weekday.allCases.map { weekday in
            let habitsForWeekday = habits.first { $0.weekday == weekday } ?? .empty(for: weekday)
            let resultsForWeekday = results.first { $0.weekday == weekday } ?? .empty(for: weekday)
            
            return PairedWeekdayHabitablesByWeekday(
                weekday: weekday,
                habits: habitsForWeekday.habitables,
                results: resultsForWeekday.habitables
            )
        }
    }
}
