import Foundation

@Observable
final class WeeklySummaryViewModel {
    private(set) var availableWeeks: [DateInterval] = []
    private(set) var digestsByWeek: [Date: [WeekdayDigest]] = [:]
    var currentWeekIndex: Int = 0

    private let digestService: WeekdayDigestService

    init() {
        digestService = WeekdayDigestService(modelContainerService: .shared)
    }

    func loadAvailableWeeks() {
        availableWeeks = digestService.fetchAvailableWeekIntervals()
        if let current = availableWeeks.first {
            loadDigests(for: current)
        }
    }

    func loadDigests(for weekInterval: DateInterval) {
        guard digestsByWeek[weekInterval.start] == nil else { return }
        digestsByWeek[weekInterval.start] = digestService.fetchWeekdayDigests(for: weekInterval)
    }

    func entries(for weekInterval: DateInterval) -> [WeeklySummaryEntry] {
        (digestsByWeek[weekInterval.start] ?? []).map {
            WeeklySummaryEntry(digest: $0, weekStart: weekInterval.start)
        }
    }
}
