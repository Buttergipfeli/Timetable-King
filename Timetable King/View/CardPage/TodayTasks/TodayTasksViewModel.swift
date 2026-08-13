import Foundation

@MainActor
@Observable
final class TodayTasksViewModel {
    private(set) var finishedEntries = [TodayTaskEntry]()
    private(set) var todoEntries = [TodayTaskEntry]()
    private(set) var futureEntries = [TodayTaskEntry]()

    func map(todayDigest: WeekdayDigest?) {
        guard let todayDigest else {
            finishedEntries = []
            todoEntries = []
            futureEntries = []
            return
        }

        let entries = todayDigest.habits.map { habit in
            TodayTaskEntry(
                habit: habit,
                result: todayDigest.results.first { $0.weekdayHabit == habit }
            )
        }

        mapCurrentEntries(entries)
        futureEntries = todayDigest.futureHabits.map { habit in
            TodayTaskEntry(
                habit: habit,
                result: nil,
                displayStatus: .future
            )
        }
    }

    func updateStatus(for entry: TodayTaskEntry, status: HabitState) {
        let updatedEntry = TodayTaskEntry(
            habit: entry.habit,
            result: entry.result,
            displayStatus: TodayTaskDisplayStatus(resultStatus: status)
        )
        let entries = (finishedEntries + todoEntries).map {
            $0.id == entry.id ? updatedEntry : $0
        }
        mapCurrentEntries(entries)
    }

    private func mapCurrentEntries(_ entries: [TodayTaskEntry]) {
        finishedEntries = entries.filter {
            $0.displayStatus == .done || $0.displayStatus == .failed
        }
        todoEntries = entries.filter { $0.displayStatus == .todo }
    }
}
