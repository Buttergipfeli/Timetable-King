import Foundation
import SwiftData

@Observable
final class TimetableKingAppViewModel {
    private(set) var weekdayDigests = [WeekdayDigest]()
    private(set) var weeklyTaskDigests = [WeekdayDigest]()
    private(set) var presentedCard: CardPage?
    var isCardPresented: Bool = false
    var isShowingSettings: Bool = false
    var presentedEntry: TodayTaskEntry?
    var presentedWeekdayDigest: WeekdayDigest?
    var presentedSummaryDigest: WeekdayDigest?
    var presentedReviewSession: TodayTaskReviewSession?

    private let weekdayDigestService: WeekdayDigestService
    private let weeklyTaskService: WeeklyTaskService
    private let todayTaskReviewService: TodayTaskReviewService
    
    var activeWeekdayDigests: [WeekdayDigest] {
        weekdayDigests.filter(\.isEmpty.not)
    }

    var activeWeeklyTaskDigests: [WeekdayDigest] {
        weeklyTaskDigests.filter(\.habits.isEmpty.not)
    }
    
    var todayDigest: WeekdayDigest? {
        weekdayDigests.first(where: \.weekday.isToday)
    }
    
    init(modelContainerService: ModelContainerService) {
        weekdayDigestService = WeekdayDigestService(modelContainerService: modelContainerService)
        weeklyTaskService = WeeklyTaskService(modelContainerService: modelContainerService)
        todayTaskReviewService = TodayTaskReviewService(modelContainerService: modelContainerService)
    }

    func load() {
        guard let fetchedDigests = weekdayDigestService.fetchWeekdayDigests(),
              let fetchedWeeklyTaskDigests = weekdayDigestService.fetchWeeklyTaskDigests() else { return }

        weekdayDigests = fetchedDigests
        weeklyTaskDigests = fetchedWeeklyTaskDigests
    }

    func refreshForActivation() {
        _ = try? todayTaskReviewService.resolvePastUndefinedTasks()
        load()

        guard canPresentReviewSession else { return }

        let entries = todayTaskReviewService.fetchPendingReviewEntries()
        presentedReviewSession = entries.isEmpty ? nil : TodayTaskReviewSession(entries: entries)
    }
    
    func open(card: CardPage) {
        presentedCard = card
        isCardPresented = true
    }

    func open(habit: WeekdayHabit) {
        guard let digest = todayDigest else { return }
        presentedEntry = TodayTaskEntry(
            habit: habit,
            result: digest.results.first { $0.weekdayHabit == habit }
        )
    }

    func open(weekdayDigest: WeekdayDigest) {
        presentedWeekdayDigest = weekdayDigest
    }

    func openSummary(weekdayDigest: WeekdayDigest) {
        presentedSummaryDigest = weekdayDigest
    }

    func deleteHistory() {
        try? weeklyTaskService.deleteHistory()
        load()
    }

    func setTodayTaskStatus(for entry: TodayTaskReviewEntry, status: HabitState) {
        try? todayTaskReviewService.setStatus(status, for: entry)
        load()
    }

    func dismissReviewSession() {
        presentedReviewSession = nil
        load()
    }

    func addWeeklyTask(title: String, weekday: Weekday, hour: Int, minute: Int) {
        try? weeklyTaskService.save(title: title, weekday: weekday, hour: hour, minute: minute)
        load()
    }

    func deleteWeeklyTask(habit: WeekdayHabit) {
        try? weeklyTaskService.delete(habit: habit)
        load()
    }

    func updateWeeklyTask(habit: WeekdayHabit, title: String, weekday: Weekday, hour: Int, minute: Int) {
        try? weeklyTaskService.update(habit: habit, title: title, weekday: weekday, hour: hour, minute: minute)
        load()
    }

    private var canPresentReviewSession: Bool {
        presentedReviewSession == nil &&
        presentedEntry == nil &&
        presentedWeekdayDigest == nil &&
        presentedSummaryDigest == nil &&
        isCardPresented.not &&
        isShowingSettings.not
    }
}
