import Foundation

@Observable
final class WeeklyTasksDayViewModel {
    var isAddingTask = false
    private(set) var habits: [WeekdayHabit] = []

    func map(digest: WeekdayDigest) {
        habits = digest.habits
    }
}
