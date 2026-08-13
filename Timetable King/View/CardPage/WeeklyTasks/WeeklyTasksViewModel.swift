import Foundation

@Observable
final class WeeklyTasksViewModel {
    var path: [Weekday] = []
    var isAddingTask = false
    private(set) var weekdayDigests: [WeekdayDigest] = []

    func map(weekdayDigests: [WeekdayDigest]) {
        self.weekdayDigests = weekdayDigests
    }
}
