struct WeekdayHabitResultsByWeekday {
    let weekday: Weekday
    let results: [WeekdayHabitResult]
}

extension WeekdayHabitResultsByWeekday: Identifiable {
    var id: Weekday {
        weekday
    }
}
