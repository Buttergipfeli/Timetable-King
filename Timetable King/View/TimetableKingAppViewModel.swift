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
    var presentedWeeklySummaryEntry: WeeklySummaryEntry?
    var presentedReviewSession: TodayTaskReviewSession?
    var isShowingOperationError = false
    private(set) var isShowingOnboarding: Bool

    private let weekdayDigestService: WeekdayDigestService
    private let weeklyTaskService: WeeklyTaskService
    private let todayTaskReviewService: TodayTaskReviewService
    private let widgetSnapshotService: any WidgetSnapshotSyncing
    private let modelContainerService: ModelContainerService
    private let onboardingStore: OnboardingStore
    private var pendingOnboardingURL: URL?
    
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
    
    init(
        modelContainerService: ModelContainerService,
        widgetSnapshotService: (any WidgetSnapshotSyncing)? = nil,
        onboardingStore: OnboardingStore = OnboardingStore()
    ) {
        self.modelContainerService = modelContainerService
        weekdayDigestService = WeekdayDigestService(modelContainerService: modelContainerService)
        weeklyTaskService = WeeklyTaskService(modelContainerService: modelContainerService)
        todayTaskReviewService = TodayTaskReviewService(modelContainerService: modelContainerService)
        self.widgetSnapshotService = widgetSnapshotService ?? WidgetSnapshotService()
        self.onboardingStore = onboardingStore
        let taskCount = (try? modelContainerService.context.fetchCount(FetchDescriptor<Habit>())) ?? 0
        isShowingOnboarding = onboardingStore.shouldPresent(hasExistingTasks: taskCount > 0)
    }

    func load() {
        guard let fetchedDigests = weekdayDigestService.fetchWeekdayDigests(),
              let fetchedWeeklyTaskDigests = weekdayDigestService.fetchWeeklyTaskDigests() else { return }

        weekdayDigests = fetchedDigests
        weeklyTaskDigests = fetchedWeeklyTaskDigests
        widgetSnapshotService.sync(
            dashboardSnapshot,
            recurringDigests: weeklyTaskDigests,
            referenceDate: .now
        )
        syncPresentedData()
    }

    func refreshForActivation() {
        guard !isShowingOnboarding else { return }

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
        presentedWeeklySummaryEntry = nil
        presentedCard = card
        isCardPresented = true
    }

    func open(entry: TodayTaskEntry) {
        presentedEntry = entry
    }

    func openWeeklySummary() {
        open(card: .weeklySummary)
    }

    func openWeeklySummary(weekday: Weekday) {
        guard let digest = weekdayDigests.first(where: { $0.weekday == weekday }),
              let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start else {
            return
        }

        presentedWeeklySummaryEntry = WeeklySummaryEntry(
            digest: digest,
            weekStart: weekStart
        )
    }

    func open(url: URL) {
        guard let destination = TimetableDeepLink.destination(for: url) else { return }

        if isShowingOnboarding {
            pendingOnboardingURL = url
            return
        }

        resetPresentation()
        load()

        switch destination {
        case .todayTasks:
            open(card: .todayTasks)
        case .weeklySummary:
            openWeeklySummary()
        case .task(let taskID):
            if let entry = todayEntries.first(where: { $0.widgetIdentifier == taskID }) {
                open(entry: entry)
            } else {
                open(card: .todayTasks)
            }
        }
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
    func addWeeklyTask(title: String, weekdays: Set<Weekday>, hour: Int, minute: Int) -> Bool {
        perform {
            try weeklyTaskService.save(title: title, weekdays: weekdays, hour: hour, minute: minute)
        }
    }

    @discardableResult
    func addOnboardingTask(title: String, weekdays: Set<Weekday>, hour: Int, minute: Int) -> Bool {
        perform(showingError: false) {
            try weeklyTaskService.save(title: title, weekdays: weekdays, hour: hour, minute: minute)
        }
    }

    func completeOnboarding() {
        onboardingStore.complete()
        isShowingOnboarding = false
        load()

        if let url = pendingOnboardingURL {
            pendingOnboardingURL = nil
            open(url: url)
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
        !isShowingOnboarding &&
        presentedReviewSession == nil &&
        presentedEntry == nil &&
        presentedWeeklySummaryEntry == nil &&
        isCardPresented.not &&
        isShowingSettings.not &&
        isAddingWeeklyTask.not
    }

    private func syncPresentedData() {
        if let presentedEntry {
            self.presentedEntry = todayEntries.first { $0.habit == presentedEntry.habit }
        }

        if let presentedWeeklySummaryEntry,
           let digest = weekdayDigests.first(where: {
               $0.weekday == presentedWeeklySummaryEntry.digest.weekday
           }),
           let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start {
            self.presentedWeeklySummaryEntry = WeeklySummaryEntry(
                digest: digest,
                weekStart: weekStart
            )
        }
    }

    private func resetPresentation() {
        presentedCard = nil
        presentedEntry = nil
        presentedWeeklySummaryEntry = nil
        presentedReviewSession = nil
        isCardPresented = false
        isShowingSettings = false
        isAddingWeeklyTask = false
    }

    private func perform(showingError: Bool = true, _ operation: () throws -> Void) -> Bool {
        do {
            try operation()
            load()
            return true
        } catch {
            handleOperationError(showingAlert: showingError)
            load()
            return false
        }
    }

    private func handleOperationError(showingAlert: Bool = true) {
        modelContainerService.context.rollback()
        isShowingOperationError = showingAlert
    }
}
