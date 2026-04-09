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

        let w1 = WeekdayHabit(hour: 7, minute: 30, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        let w2 = WeekdayHabit(hour: 8, minute: 0, weekdayRawValue: Weekday.thursday.rawValue, habit: trash)
        let w3 = WeekdayHabit(hour: 21, minute: 15, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        let w4 = WeekdayHabit(hour: 21, minute: 15, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        let w5 = WeekdayHabit(hour: 22, minute: 00, weekdayRawValue: Weekday.thursday.rawValue, habit: sleep)
        let createdAt = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now
        w1.createdAt = createdAt
        w2.createdAt = createdAt
        w3.createdAt = createdAt
        w4.createdAt = createdAt
        w5.createdAt = createdAt
        context.insert(w1)
        context.insert(w2)
        context.insert(w3)
        context.insert(w4)
        context.insert(w5)
        
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let thursday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 3, to: weekStart) ?? weekStart)
        context.insert(WeekdayHabitResult(day: thursday, weekdayHabit: w1, status: .none))
        context.insert(WeekdayHabitResult(day: thursday, weekdayHabit: w2, status: .none))
        context.insert(WeekdayHabitResult(day: thursday, weekdayHabit: w3, status: .done))

        insertHistoryTestData(
            into: context,
            habits: [w1, w2, w3, w4, w5],
            currentWeekStart: weekStart
        )
    }
}

extension Timetable_KingApp {
    func insertHistoryTestData(into context: ModelContext, habits: [WeekdayHabit], currentWeekStart: Date) {
        guard habits.count == 5 else { return }

        let previousWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? currentWeekStart
        let twoWeeksAgoStart = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: currentWeekStart) ?? currentWeekStart

        let previousWeekWednesday = historyDay(from: previousWeekStart, dayOffset: 2)
        let previousWeekThursday = historyDay(from: previousWeekStart, dayOffset: 3)
        let twoWeeksAgoWednesday = historyDay(from: twoWeeksAgoStart, dayOffset: 2)
        let twoWeeksAgoThursday = historyDay(from: twoWeeksAgoStart, dayOffset: 3)

        context.insert(WeekdayHabitResult(day: previousWeekWednesday, weekdayHabit: habits[0], status: .done))
        context.insert(WeekdayHabitResult(day: previousWeekWednesday, weekdayHabit: habits[1], status: .failed))
        context.insert(WeekdayHabitResult(day: previousWeekWednesday, weekdayHabit: habits[2], status: .done))
        context.insert(WeekdayHabitResult(day: previousWeekThursday, weekdayHabit: habits[3], status: .failed))
        context.insert(WeekdayHabitResult(day: previousWeekThursday, weekdayHabit: habits[4], status: .done))

        context.insert(WeekdayHabitResult(day: twoWeeksAgoWednesday, weekdayHabit: habits[0], status: .failed))
        context.insert(WeekdayHabitResult(day: twoWeeksAgoWednesday, weekdayHabit: habits[1], status: .done))
        context.insert(WeekdayHabitResult(day: twoWeeksAgoWednesday, weekdayHabit: habits[2], status: .failed))
        context.insert(WeekdayHabitResult(day: twoWeeksAgoThursday, weekdayHabit: habits[3], status: .done))
        context.insert(WeekdayHabitResult(day: twoWeeksAgoThursday, weekdayHabit: habits[4], status: .failed))
    }

    private func historyDay(from weekStart: Date, dayOffset: Int) -> Date {
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
        return Calendar.current.startOfDay(for: date)
    }
}
