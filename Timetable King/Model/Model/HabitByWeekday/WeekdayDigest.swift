struct WeekdayDigest: Equatable, Hashable {
    let weekday: Weekday
    let habits: [WeekdayHabit]
    let results: [WeekdayHabitResult]
    let futureHabits: [WeekdayHabit]
    
    init(
        weekday: Weekday,
        habits: [WeekdayHabit],
        results: [WeekdayHabitResult],
        futureHabits: [WeekdayHabit] = []
    ) {
        self.weekday = weekday
        self.habits = habits
        self.results = results
        self.futureHabits = futureHabits
    }
    
    var isEmpty: Bool {
        return habits.isEmpty && results.isEmpty && futureHabits.isEmpty
    }
}

extension WeekdayDigest: Identifiable {
    var id: Weekday {
        weekday
    }
}
