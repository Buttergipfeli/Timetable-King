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

    init(modelContainerService: ModelContainerService) {
        digestService = WeekdayDigestService(modelContainerService: modelContainerService)
    }

    func loadAvailableWeeks() {
        let currentWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start
        availableWeeks = digestService.fetchAvailableWeekIntervals()
            .sorted { $0.start < $1.start }

        if let currentWeekStart,
           let currentIndex = availableWeeks.firstIndex(where: {
               Calendar.current.isDate($0.start, inSameDayAs: currentWeekStart)
           }) {
            currentWeekIndex = currentIndex
            loadDigests(for: availableWeeks[currentIndex])
        } else if let current = availableWeeks.last {
            currentWeekIndex = max(availableWeeks.count - 1, 0)
            loadDigests(for: current)
        }
    }

    func loadDigests(for weekInterval: DateInterval) {
        guard digestsByWeek[weekInterval.start] == nil else { return }
        digestsByWeek[weekInterval.start] = digestService.fetchWeekdayDigests(for: weekInterval)
    }

    func reloadDigests(forWeekStartingAt weekStart: Date) {
        guard let weekInterval = availableWeeks.first(where: {
            Calendar.current.isDate($0.start, inSameDayAs: weekStart)
        }) else { return }

        digestsByWeek[weekInterval.start] = digestService.fetchWeekdayDigests(for: weekInterval)
    }

    func entries(for weekInterval: DateInterval) -> [WeeklySummaryEntry] {
        (digestsByWeek[weekInterval.start] ?? []).map {
            WeeklySummaryEntry(digest: $0, weekStart: weekInterval.start)
        }
    }
}
