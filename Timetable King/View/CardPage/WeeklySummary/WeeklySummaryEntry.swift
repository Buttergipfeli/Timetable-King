import Foundation

struct WeeklySummaryEntry: Identifiable, Hashable {
    let digest: WeekdayDigest
    let weekStart: Date

    var id: String { "\(weekStart.timeIntervalSinceReferenceDate)-\(digest.weekday.rawValue)" }

    var completedCount: Int {
        digest.results.filter(\.isDone).count
    }

    var totalCount: Int {
        digest.habits.count
    }

    var futureCount: Int {
        digest.futureHabits.count
    }

    var completionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}
