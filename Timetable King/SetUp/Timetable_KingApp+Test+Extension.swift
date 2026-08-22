import Foundation
import SwiftData

extension Timetable_KingApp {
    static func setUpTestData(into context: ModelContext) {
        let sport = Habit(title: "Training")
        let trash = Habit(title: "Bring trash out")
        let sleep = Habit(title: "Go to sleep directly")
        let morningRoutine = Habit(title: "Morning routine")
        context.insert(sport)
        context.insert(trash)
        context.insert(sleep)
        context.insert(morningRoutine)

        let w1 = WeekdayHabit(hour: 7, minute: 30, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        let w2 = WeekdayHabit(hour: 8, minute: 0, weekdayRawValue: Weekday.thursday.rawValue, habit: trash)
        let w3 = WeekdayHabit(hour: 21, minute: 15, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        let w4 = WeekdayHabit(hour: 21, minute: 45, weekdayRawValue: Weekday.thursday.rawValue, habit: sport)
        let w5 = WeekdayHabit(hour: 22, minute: 00, weekdayRawValue: Weekday.thursday.rawValue, habit: sleep)
        let morningTasks = Weekday.allCases
            .filter { $0 != .tuesday }
            .map { weekday in
                WeekdayHabit(
                    hour: 8,
                    minute: 0,
                    weekdayRawValue: weekday.rawValue,
                    habit: morningRoutine
                )
            }
        let saturdayTaskData: [(title: String, hour: Int, minute: Int)] = [
            ("Grocery shopping", 9, 30),
            ("Clean apartment", 13, 0),
            ("Weekly planning", 17, 30),
            ("Read a book", 22, 15),
            ("Evening stretch", 23, 0),
            ("Prepare for sleep", 23, 30)
        ]
        let saturdayTasks = saturdayTaskData.map { taskData in
            let habit = Habit(title: taskData.title)
            context.insert(habit)
            return WeekdayHabit(
                hour: taskData.hour,
                minute: taskData.minute,
                weekdayRawValue: Weekday.saturday.rawValue,
                habit: habit
            )
        }
        let createdAt = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: .now) ?? .now
        let thursdayTasks = [w1, w2, w3, w4, w5]

        for task in thursdayTasks + morningTasks + saturdayTasks {
            task.createdAt = createdAt
            context.insert(task)
        }
        
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let thursday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 3, to: weekStart) ?? weekStart)
        context.insert(WeekdayHabitResult(day: thursday, weekdayHabit: w1, status: .none))
        context.insert(WeekdayHabitResult(day: thursday, weekdayHabit: w2, status: .none))
        context.insert(WeekdayHabitResult(day: thursday, weekdayHabit: w3, status: .done))

        insertHistoryTestData(
            into: context,
            habits: thursdayTasks,
            currentWeekStart: weekStart
        )
    }
}

extension Timetable_KingApp {
    static func insertHistoryTestData(into context: ModelContext, habits: [WeekdayHabit], currentWeekStart: Date) {
        guard habits.count == 5 else { return }

        for weekOffset in 1...200 {
            let weekStart = Calendar.current.date(
                byAdding: .weekOfYear,
                value: -weekOffset,
                to: currentWeekStart
            ) ?? currentWeekStart
            let thursday = historyDay(from: weekStart, dayOffset: 3)
            let completedCount = weekOffset % (habits.count + 1)

            for (habitIndex, habit) in habits.enumerated() {
                let status: HabitState = habitIndex < completedCount ? .done : .failed
                context.insert(WeekdayHabitResult(day: thursday, weekdayHabit: habit, status: status))
            }
        }
    }

    private static func historyDay(from weekStart: Date, dayOffset: Int) -> Date {
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
        return Calendar.current.startOfDay(for: date)
    }
}
