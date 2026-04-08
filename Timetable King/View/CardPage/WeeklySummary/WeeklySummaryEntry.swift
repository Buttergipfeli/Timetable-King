import Foundation

struct WeeklySummaryEntry: Identifiable, Hashable {
    let digest: WeekdayDigest

    var id: Weekday { digest.weekday }

    var completedCount: Int {
        digest.results.filter(\.isDone).count
    }

    var totalCount: Int {
        digest.habits.count
    }

    var completionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}
