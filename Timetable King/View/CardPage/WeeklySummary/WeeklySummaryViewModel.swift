import Foundation

@Observable
final class WeeklySummaryViewModel {
    private(set) var entries: [WeeklySummaryEntry] = []

    func map(weekdayDigests: [WeekdayDigest]) {
        entries = weekdayDigests.map { WeeklySummaryEntry(digest: $0) }
    }
}
