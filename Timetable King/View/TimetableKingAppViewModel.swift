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

    var todayEntries: [TodayTaskEntry] {
        guard let todayDigest else { return [] }

        return todayDigest.habits.map { habit in
            TodayTaskEntry(
                habit: habit,
                result: todayDigest.results.first { $0.weekdayHabit == habit }
            )
        }
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
        syncPresentedData()
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

    func open(entry: TodayTaskEntry) {
        presentedEntry = entry
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

    func updateTodayTaskStatus(for entry: TodayTaskEntry, status: HabitState) {
        try? todayTaskReviewService.setStatus(status, for: entry.habit, on: .now)
        load()

        if presentedEntry?.habit == entry.habit {
            presentedEntry = todayEntries.first { $0.habit == entry.habit }
        }
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

    private func syncPresentedData() {
        if let presentedEntry {
            self.presentedEntry = todayEntries.first { $0.habit == presentedEntry.habit }
        }

        if let presentedWeekdayDigest {
            self.presentedWeekdayDigest = weeklyTaskDigests.first { $0.weekday == presentedWeekdayDigest.weekday }
        }

        if let presentedSummaryDigest {
            self.presentedSummaryDigest = weekdayDigests.first { $0.weekday == presentedSummaryDigest.weekday }
        }
    }
}
