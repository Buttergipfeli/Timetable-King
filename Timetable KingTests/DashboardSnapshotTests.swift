import Foundation
import Testing
@testable import Timetable_King

@MainActor
struct DashboardSnapshotTests {
    @Test
    func exposesCompletedAndTotalValuesForEachWeekday() {
        let habit = Habit(title: "Saturday walk")
        let schedule = WeekdayHabit(
            hour: 9,
            minute: 0,
            weekdayRawValue: Weekday.saturday.rawValue,
            habit: habit
        )
        let result = WeekdayHabitResult(day: .now, weekdayHabit: schedule, status: .done)
        let saturdayDigest = WeekdayDigest(
            weekday: .saturday,
            habits: [schedule],
            results: [result]
        )
        let snapshot = DashboardSnapshot(
            todayEntries: [],
            completedTodayCount: 0,
            totalTodayCount: 0,
            nextTask: nil,
            weekdayDigests: [saturdayDigest],
            weeklyCompletedCount: 1,
            weeklyTotalCount: 1,
            weeklyTaskCount: 1,
            activeWeekdayCount: 1,
            weeklyTaskWeekdays: [.saturday]
        )

        #expect(snapshot.progress(for: .saturday).displayValue == "1/1")
        #expect(snapshot.progress(for: .monday).displayValue == "–")
    }
}
