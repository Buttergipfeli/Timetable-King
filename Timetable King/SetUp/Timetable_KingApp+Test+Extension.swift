import Foundation
import SwiftData

extension Timetable_KingApp {
    func setUpTestData(into context: ModelContext) {
        let sport = Habit(title: "Training")
        let trash = Habit(title: "Bring trash out")
        context.insert(sport)
        context.insert(trash)

        let w1 = WeekdayHabit(hour: 7, minute: 30, weekdayRawValue: Weekday.monday.rawValue, habit: sport)
        let w2 = WeekdayHabit(hour: 20, minute: 0, weekdayRawValue: Weekday.monday.rawValue, habit: trash)
        let w3 = WeekdayHabit(hour: 21, minute: 15, weekdayRawValue: Weekday.monday.rawValue, habit: sport)
        let w4 = WeekdayHabit(hour: 21, minute: 15, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        context.insert(w1)
        context.insert(w2)
        context.insert(w3)
        context.insert(w4)
        
//        let today = Calendar.current.startOfDay(for: .now)
//        context.insert(WeekdayHabitResult(day: today, weekdayHabit: w1, status: .none))
//        context.insert(WeekdayHabitResult(day: today, weekdayHabit: w2, status: .done))
//        context.insert(WeekdayHabitResult(day: today, weekdayHabit: w1, status: .failed))
    }
}
