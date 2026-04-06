import Foundation

@Observable
final class WeeklyTasksDayViewModel {
    var isAddingTask = false
    var selectedHabit: WeekdayHabit?
    private(set) var habits: [WeekdayHabit] = []

    func map(digest: WeekdayDigest) {
        habits = digest.habits
    }
}
