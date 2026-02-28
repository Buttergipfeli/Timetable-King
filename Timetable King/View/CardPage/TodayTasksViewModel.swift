import Foundation

@MainActor
@Observable
final class TodayTasksViewModel {
    private(set) var finishedEntries = [TodayTaskEntry]()
    private(set) var todoEntries = [TodayTaskEntry]()

    func map(todayDigest: WeekdayDigest?) {
        guard let todayDigest else {
            finishedEntries = []
            todoEntries = []
            return
        }

        let resultsByHabit = Dictionary(
            uniqueKeysWithValues: todayDigest.results.map { result in
                (ObjectIdentifier(result.weekdayHabit), result)
            }
        )

        let entries = todayDigest.habits
            .sorted(by: Self.sortHabits)
            .map { habit in
                TodayTaskEntry(
                    habit: habit,
                    result: resultsByHabit[ObjectIdentifier(habit)]
                )
            }

        finishedEntries = entries.filter { $0.result != nil }
        todoEntries = entries.filter { $0.result == nil }
    }

    private static func sortHabits(lhs: WeekdayHabit, rhs: WeekdayHabit) -> Bool {
        if lhs.hour != rhs.hour {
            return lhs.hour < rhs.hour
        }

        if lhs.minute != rhs.minute {
            return lhs.minute < rhs.minute
        }

        return lhs.habit.title.localizedCaseInsensitiveCompare(rhs.habit.title) == .orderedAscending
    }
}
