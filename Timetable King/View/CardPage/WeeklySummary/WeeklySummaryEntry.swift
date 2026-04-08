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

    var performanceEmoji: String {
        if isCurrentWeek, digest.weekday.isFuture {
            return "⏳"
        }

        guard totalCount > 0 else { return "😶" }

        switch completionPercentage {
        case 0:          return "😭"
        case 0..<0.25:   return "😢"
        case 0.25..<0.5: return "😬"
        case 0.5..<0.75: return "🙂"
        case 0.75..<1.0: return "😄"
        default:         return "🤩"
        }
    }

    var isCurrentWeek: Bool {
        guard let currentWeek = Calendar.current.dateInterval(of: .weekOfYear, for: .now) else { return false }
        return Calendar.current.isDate(weekStart, inSameDayAs: currentWeek.start)
    }

    var isCurrentDay: Bool {
        isCurrentWeek && digest.weekday.isToday
    }
}
