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

    var completionScore: CompletionScore {
        CompletionScore(completedCount: completedCount, totalCount: totalCount)
    }

    var performanceEmoji: String {
        if isCurrentWeek, digest.weekday.isFuture {
            return "⏳"
        }

        return completionScore.performanceEmoji
    }

    var isCurrentWeek: Bool {
        guard let currentWeek = Calendar.current.dateInterval(of: .weekOfYear, for: .now) else { return false }
        return Calendar.current.isDate(weekStart, inSameDayAs: currentWeek.start)
    }

    var isCurrentDay: Bool {
        isCurrentWeek && digest.weekday.isToday
    }
}
