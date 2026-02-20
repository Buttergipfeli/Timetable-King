import Foundation
import SwiftData

extension Timetable_KingApp {
    func setUpTestData(into context: ModelContext) {
        let sport = Habit(title: "Sport")
        let trash = Habit(title: "Müll raus")
        context.insert(sport)
        context.insert(trash)

        let w1 = WeekdayHabit(hour: 7, minute: 30, weekdayRawValue: Weekday.monday.rawValue, habit: sport)
        let w2 = WeekdayHabit(hour: 20, minute: 0, weekdayRawValue: Weekday.monday.rawValue, habit: trash)
        context.insert(w1)
        context.insert(w2)
        
        let today = Calendar.current.startOfDay(for: .now)
        context.insert(WeekdayHabitResult(day: today, weekdayHabit: w1, status: .none))
    }
}
