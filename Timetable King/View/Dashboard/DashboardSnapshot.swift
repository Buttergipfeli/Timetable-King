struct DashboardSnapshot {
    let todayEntries: [TodayTaskEntry]
    let completedTodayCount: Int
    let totalTodayCount: Int
    let nextTask: TodayTaskEntry?
    let weekdayDigests: [WeekdayDigest]
    let weeklyCompletedCount: Int
    let weeklyTotalCount: Int
    let weeklyTaskCount: Int
    let activeWeekdayCount: Int
    let weeklyTaskWeekdays: Set<Weekday>

    var weeklySkippedCount: Int {
        weekdayDigests.reduce(0) { $0 + $1.results.filter { $0.status == .skipped }.count }
    }

    var weeklyCompletionPercentage: Double {
        guard weeklyTotalCount > 0 else { return 0 }
        return Double(weeklyCompletedCount) / Double(weeklyTotalCount)
    }

    func progress(for weekday: Weekday) -> DashboardWeekdayProgress {
        guard let digest = weekdayDigests.first(where: { $0.weekday == weekday }) else {
            return DashboardWeekdayProgress(completedCount: 0, totalCount: 0, skippedCount: 0)
        }

        return DashboardWeekdayProgress(
            completedCount: digest.results.filter(\.isDone).count,
            totalCount: digest.scoredTaskCount,
            skippedCount: digest.results.filter { $0.status == .skipped }.count
        )
    }

    func hasWeeklyTasks(on weekday: Weekday) -> Bool {
        weeklyTaskWeekdays.contains(weekday)
    }
}

struct DashboardWeekdayProgress {
    let completedCount: Int
    let totalCount: Int
    let skippedCount: Int

    var displayValue: String {
        totalCount > 0 ? "\(completedCount)/\(totalCount)" : "–"
    }

    var isComplete: Bool {
        totalCount > 0 && completedCount == totalCount
    }
}
