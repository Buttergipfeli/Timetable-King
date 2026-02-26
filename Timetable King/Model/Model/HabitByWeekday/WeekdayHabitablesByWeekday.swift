struct WeekdayHabitablesByWeekday<Habitable: WeekdayHabitable> {
    let weekday: Weekday
    let habitables: [Habitable]
    
    func appending(_ habitable: Habitable) -> WeekdayHabitablesByWeekday {
        WeekdayHabitablesByWeekday(weekday: weekday, habitables: habitables + [habitable])
    }
    
    static func empty(for weekday: Weekday) -> WeekdayHabitablesByWeekday<Habitable> {
        WeekdayHabitablesByWeekday(weekday: weekday, habitables: [])
    }
}

extension WeekdayHabitablesByWeekday: Identifiable {
    var id: String {
        "\(weekday.rawValue)\(Habitable.self)"
    }
}
