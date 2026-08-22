import Foundation
import SwiftData

@Observable
final class TimetableKingAppViewModel {
    private(set) var weekdayDigests = [WeekdayDigest]()
    private(set) var weeklyTaskDigests = [WeekdayDigest]()
    private(set) var presentedCard: CardPage?
    var isCardPresented: Bool = false
    var isShowingSettings: Bool = false
    var isAddingWeeklyTask: Bool = false
    var presentedEntry: TodayTaskEntry?
    var presentedReviewSession: TodayTaskReviewSession?
    var isShowingOperationError = false

    private let weekdayDigestService: WeekdayDigestService
    private let weeklyTaskService: WeeklyTaskService
    private let todayTaskReviewService: TodayTaskReviewService
    private let modelContainerService: ModelContainerService
    
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

    var dashboardSnapshot: DashboardSnapshot {
        let completedTodayCount = todayEntries.filter { $0.displayStatus == .done }.count
        let weeklyCompletedCount = weekdayDigests
            .flatMap(\.results)
            .filter(\.isDone)
            .count
        let weeklyTotalCount = weekdayDigests.reduce(0) { $0 + $1.habits.count }
        let activeWeeklyDigests = weeklyTaskDigests.filter { $0.habits.isEmpty.not }

        return DashboardSnapshot(
            todayEntries: todayEntries,
            completedTodayCount: completedTodayCount,
            totalTodayCount: todayEntries.count,
            nextTask: todayEntries.first { $0.displayStatus == .todo },
            weekdayDigests: weekdayDigests,
            weeklyCompletedCount: weeklyCompletedCount,
            weeklyTotalCount: weeklyTotalCount,
            weeklyTaskCount: activeWeeklyDigests.reduce(0) { $0 + $1.habits.count },
            activeWeekdayCount: activeWeeklyDigests.count,
            weeklyTaskWeekdays: Set(activeWeeklyDigests.map(\.weekday))
        )
    }
    
    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
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
        do {
            try todayTaskReviewService.resolvePastUndefinedTasks()
        } catch {
            handleOperationError()
        }
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

    @discardableResult
    func deleteHistory() -> Bool {
        perform {
            try weeklyTaskService.deleteHistory()
            presentedEntry = nil
            presentedReviewSession = nil
        }
    }

    @discardableResult
    func setTodayTaskStatus(for entry: TodayTaskReviewEntry, status: HabitState) -> Bool {
        perform {
            try todayTaskReviewService.setStatus(status, for: entry)
        }
    }

    @discardableResult
    func updateTodayTaskStatus(for entry: TodayTaskEntry, status: HabitState) -> Bool {
        perform {
            try todayTaskReviewService.setStatus(status, for: entry.habit, on: .now)
        }
    }

    func dismissReviewSession() {
        presentedReviewSession = nil
        load()
    }

    @discardableResult
    func addWeeklyTask(title: String, weekday: Weekday, hour: Int, minute: Int) -> Bool {
        perform {
            try weeklyTaskService.save(title: title, weekday: weekday, hour: hour, minute: minute)
        }
    }

    @discardableResult
    func deleteWeeklyTask(habit: WeekdayHabit) -> Bool {
        perform {
            try weeklyTaskService.delete(habit: habit)
        }
    }

    @discardableResult
    func updateWeeklyTask(habit: WeekdayHabit, title: String, weekday: Weekday, hour: Int, minute: Int) -> Bool {
        perform {
            try weeklyTaskService.update(habit: habit, title: title, weekday: weekday, hour: hour, minute: minute)
        }
    }

    private var canPresentReviewSession: Bool {
        presentedReviewSession == nil &&
        presentedEntry == nil &&
        isCardPresented.not &&
        isShowingSettings.not &&
        isAddingWeeklyTask.not
    }

    private func syncPresentedData() {
        if let presentedEntry {
            self.presentedEntry = todayEntries.first { $0.habit == presentedEntry.habit }
        }
    }

    private func perform(_ operation: () throws -> Void) -> Bool {
        do {
            try operation()
            load()
            return true
        } catch {
            handleOperationError()
            load()
            return false
        }
    }

    private func handleOperationError() {
        modelContainerService.context.rollback()
        isShowingOperationError = true
    }
}
