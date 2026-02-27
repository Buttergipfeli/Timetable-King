struct WeekdayDigest: Equatable {
    let weekday: Weekday
    let habits: [WeekdayHabit]
    let results: [WeekdayHabitResult]
    
    init(weekday: Weekday, habits: [WeekdayHabit], results: [WeekdayHabitResult]) {
        self.weekday = weekday
        self.habits = habits
        self.results = results
    }
    
    var isEmpty: Bool {
        return habits.isEmpty && results.isEmpty
    }
}

extension WeekdayDigest: Identifiable {
    var id: Weekday {
        weekday
    }
}
