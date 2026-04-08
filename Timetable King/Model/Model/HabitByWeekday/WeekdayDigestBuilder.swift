struct WeekdayDigestBuilder {
    let habits: [WeekdayBucket<WeekdayHabit>]
    let results: [WeekdayBucket<WeekdayHabitResult>]
    let futureHabits: [WeekdayBucket<WeekdayHabit>]
    
    func build() -> [WeekdayDigest] {
        Weekday.allCases.map { weekday in
            let habitBucket = habits.first { $0.weekday == weekday } ?? .empty(weekday)
            let resultBucket = results.first { $0.weekday == weekday } ?? .empty(weekday)
            let futureHabitBucket = futureHabits.first { $0.weekday == weekday } ?? .empty(weekday)
            
            return WeekdayDigest(
                weekday: weekday,
                habits: habitBucket.items,
                results: resultBucket.items,
                futureHabits: futureHabitBucket.items
            )
        }
    }
}
