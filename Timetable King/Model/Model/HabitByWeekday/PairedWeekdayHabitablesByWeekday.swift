struct PairedWeekdayHabitablesByWeekday {
    let weekday: Weekday
    let habits: [WeekdayHabit]
    let results: [WeekdayHabitResult]
    
    var isEmpty: Bool {
        return habits.isEmpty && results.isEmpty
    }
}

extension PairedWeekdayHabitablesByWeekday: Identifiable {
    var id: Weekday {
        weekday
    }
}
