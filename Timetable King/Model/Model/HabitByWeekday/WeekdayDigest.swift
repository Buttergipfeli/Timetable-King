struct WeekdayDigest {
    let weekday: Weekday
    let habits: [WeekdayHabit]
    let results: [WeekdayHabitResult]
    
    var isEmpty: Bool {
        return habits.isEmpty && results.isEmpty
    }
}

extension WeekdayDigest: Identifiable {
    var id: Weekday {
        weekday
    }
}
