import Foundation

@Observable
final class TodayTaskDetailViewModel {
    var currentStatus: TodayTaskDisplayStatus = .todo

    func map(entry: TodayTaskEntry) {
        currentStatus = entry.displayStatus
    }

    func setStatus(_ status: HabitState) {
        currentStatus = TodayTaskDisplayStatus(resultStatus: status)
    }
}
