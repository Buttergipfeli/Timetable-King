import Foundation

@Observable
final class WeeklySummaryViewModel {
    private(set) var availableWeeks: [DateInterval] = []
    private(set) var digestsByWeek: [Date: [WeekdayDigest]] = [:]
    private(set) var overallScore = CompletionScore(completedCount: 0, totalCount: 0)
    private(set) var isLoadingHistory = false
    var currentWeekIndex: Int = 0

    private let digestService: WeekdayDigestService
    private let historyOverviewService: WeeklyHistoryOverviewService
    private var hasLoadedCurrentWeek = false
    private var hasLoadedHistory = false

    convenience init() {
        self.init(modelContainerService: .shared)
    }

    init(modelContainerService: ModelContainerService) {
        digestService = WeekdayDigestService(modelContainerService: modelContainerService)
        historyOverviewService = WeeklyHistoryOverviewService(
            modelContainer: modelContainerService.modelContainer
        )
    }

    func loadCurrentWeek(referenceDate: Date = .now) {
        guard !hasLoadedCurrentWeek,
              let currentWeek = Calendar.current.dateInterval(
                of: .weekOfYear,
                for: referenceDate
              ) else {
            return
        }

        availableWeeks = [currentWeek]
        currentWeekIndex = 0
        loadDigests(for: currentWeek)
        overallScore = score(for: currentWeek)
        hasLoadedCurrentWeek = true
    }

    func loadAvailableWeeks(referenceDate: Date = .now) async {
        loadCurrentWeek(referenceDate: referenceDate)
        await loadHistoryOverview(referenceDate: referenceDate)
    }

    func loadHistoryOverview(referenceDate: Date = .now) async {
        guard !isLoadingHistory, !hasLoadedHistory else { return }

        isLoadingHistory = true
        defer { isLoadingHistory = false }

        guard let overview = try? await historyOverviewService.fetch(referenceDate: referenceDate) else {
            return
        }

        apply(overview, referenceDate: referenceDate)
        hasLoadedHistory = true
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

    func reloadHistoryOverview(referenceDate: Date = .now) async {
        guard let overview = try? await historyOverviewService.fetch(referenceDate: referenceDate) else {
            return
        }

        apply(overview, referenceDate: referenceDate)
        hasLoadedHistory = true
    }

    func entries(for weekInterval: DateInterval) -> [WeeklySummaryEntry] {
        (digestsByWeek[weekInterval.start] ?? []).map {
            WeeklySummaryEntry(digest: $0, weekStart: weekInterval.start)
        }
    }

    func score(for weekInterval: DateInterval) -> CompletionScore {
        score(for: digestsByWeek[weekInterval.start] ?? [])
    }

    private func score(for digests: [WeekdayDigest]) -> CompletionScore {
        CompletionScore(
            completedCount: digests.flatMap(\.results).filter(\.isDone).count,
            totalCount: digests.reduce(0) { $0 + $1.habits.count }
        )
    }

    private func apply(_ overview: WeeklyHistoryOverview, referenceDate: Date) {
        let selectedWeekStart = availableWeeks.indices.contains(currentWeekIndex)
            ? availableWeeks[currentWeekIndex].start
            : nil
        availableWeeks = overview.availableWeeks
        overallScore = overview.overallScore

        if let selectedWeekStart,
           let selectedIndex = availableWeeks.firstIndex(where: {
               Calendar.current.isDate($0.start, inSameDayAs: selectedWeekStart)
           }) {
            currentWeekIndex = selectedIndex
            return
        }

        guard let currentWeekStart = Calendar.current.dateInterval(
            of: .weekOfYear,
            for: referenceDate
        )?.start else {
            currentWeekIndex = max(availableWeeks.count - 1, 0)
            return
        }

        currentWeekIndex = availableWeeks.firstIndex(where: {
            Calendar.current.isDate($0.start, inSameDayAs: currentWeekStart)
        }) ?? max(availableWeeks.count - 1, 0)
    }
}
