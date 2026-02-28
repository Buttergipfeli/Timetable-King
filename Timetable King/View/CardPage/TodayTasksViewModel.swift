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

        var entries = todayDigest.habits.map { habit in
            TodayTaskEntry(
                habit: habit,
                result: todayDigest.results.first { $0.weekdayHabit == habit }
            )
        }

        let finishedUnfinishedIndex = entries.partition { entry in
            entry.result?.isDone == true
        }

        finishedEntries = Array(entries[finishedUnfinishedIndex...])
        todoEntries = Array(entries[..<finishedUnfinishedIndex])
    }
}
