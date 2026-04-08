import Foundation
import SwiftData

extension Timetable_KingApp {
    func setUpTestData(into context: ModelContext) {
        let sport = Habit(title: "Training")
        let trash = Habit(title: "Bring trash out")
        let sleep = Habit(title: "Go to sleep directly")
        context.insert(sport)
        context.insert(trash)
        context.insert(sleep)

        let w1 = WeekdayHabit(hour: 7, minute: 30, weekdayRawValue: Weekday.tuesday.rawValue, habit: sport)
        let w2 = WeekdayHabit(hour: 20, minute: 0, weekdayRawValue: Weekday.tuesday.rawValue, habit: trash)
        let w3 = WeekdayHabit(hour: 21, minute: 15, weekdayRawValue: Weekday.tuesday.rawValue, habit: sport)
        let w4 = WeekdayHabit(hour: 21, minute: 15, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        let w5 = WeekdayHabit(hour: 22, minute: 00, weekdayRawValue: Weekday.thursday.rawValue, habit: sleep)
        context.insert(w1)
        context.insert(w2)
        context.insert(w3)
        context.insert(w4)
        context.insert(w5)
        
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let tuesday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 0, to: weekStart) ?? weekStart)
        context.insert(WeekdayHabitResult(day: tuesday, weekdayHabit: w1, status: .failed))
        context.insert(WeekdayHabitResult(day: tuesday, weekdayHabit: w2, status: .done))
        context.insert(WeekdayHabitResult(day: tuesday, weekdayHabit: w3, status: .done))
//        context.insert(WeekdayHabitResult(day: monday, weekdayHabit: w1, status: .failed))
    }
}
