import Foundation

@Observable
final class TodayTaskReviewViewModel {
    private(set) var entries = [TodayTaskReviewEntry]()
    private(set) var totalCount = 0

    var currentEntry: TodayTaskReviewEntry? {
        entries.first
    }

    var currentStep: Int {
        min(totalCount - entries.count + 1, totalCount)
    }

    func map(session: TodayTaskReviewSession) {
        entries = session.entries
        totalCount = session.entries.count
    }

    func advance() {
        guard entries.isEmpty.not else { return }
        entries.removeFirst()
    }
}
