import Foundation

@MainActor
@Observable
final class TodayTasksViewModel {
    struct Entry: Identifiable {
        enum State {
            case done
            case failed
            case undefined
        }

        let habit: WeekdayHabit
        let result: WeekdayHabitResult?

        var id: ObjectIdentifier {
            ObjectIdentifier(habit)
        }

        var title: String {
            habit.habit.title
        }

        var timeString: String {
            habit.timeString
        }

        var statusTitle: String {
            switch state {
            case .done:
                "Finished"
            case .failed:
                "Not done"
            case .undefined:
                "Undefined"
            }
        }

        var statusDescription: String {
            switch state {
            case .done:
                "This task has been completed."
            case .failed:
                "This task was marked as not completed."
            case .undefined:
                "This task does not have a defined result yet."
            }
        }

        var detailDescription: String {
            switch state {
            case .done:
                "Scheduled at \(timeString). This task is already finished."
            case .failed:
                "Scheduled at \(timeString). This task has a defined result and is marked as not done."
            case .undefined:
                "Scheduled at \(timeString). This task does not have a status yet."
            }
        }

        var state: State {
            switch result?.status {
            case .done?:
                .done
            case .failed?:
                .failed
            case nil:
                .undefined
            }
        }
    }

    private(set) var finishedEntries = [Entry]()
    private(set) var todoEntries = [Entry]()

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
                Entry(
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
