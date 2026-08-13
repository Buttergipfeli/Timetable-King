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

extension WeekdayDigest {
    var performanceEmoji: String {
        guard !weekday.isFuture else { return "⏳" }
        let total = habits.count
        guard total > 0 else { return "😶" }
        let completed = results.filter(\.isDone).count
        let percentage = Double(completed) / Double(total)
        switch percentage {
        case 0:          return "😭"
        case 0..<0.25:   return "😢"
        case 0.25..<0.5: return "😬"
        case 0.5..<0.75: return "🙂"
        case 0.75..<1.0: return "😄"
        default:         return "🤩"
        }
    }
}
