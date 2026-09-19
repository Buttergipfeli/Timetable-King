import Foundation
import SwiftData

struct WeeklyHistoryOverview: Equatable, Sendable {
    let availableWeeks: [DateInterval]
    let overallScore: CompletionScore
}

@ModelActor
actor WeeklyHistoryOverviewService {
    func fetch(
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) throws -> WeeklyHistoryOverview {
        let habits = try modelContext.fetch(FetchDescriptor<WeekdayHabit>())
        let results = try modelContext.fetch(FetchDescriptor<WeekdayHabitResult>())
        let historyDeletedDayStart = try fetchHistoryDeletedDayStart(calendar: calendar)
        let visibleResults = results.filter { result in
            guard let historyDeletedDayStart else { return true }
            return result.day >= historyDeletedDayStart
        }
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: referenceDate)
        let intervals = availableWeekIntervals(
            results: visibleResults,
            currentWeek: currentWeek,
            calendar: calendar
        )
        let resultsByWeekStart = Dictionary(grouping: visibleResults) { result in
            calendar.dateInterval(of: .weekOfYear, for: result.day)?.start
                ?? calendar.startOfDay(for: result.day)
        }
        let totalCount = intervals.reduce(0) { count, interval in
            count + taskCount(
                in: interval,
                habits: habits,
                results: resultsByWeekStart[interval.start] ?? [],
                historyDeletedDayStart: historyDeletedDayStart,
                calendar: calendar
            )
        }

        return WeeklyHistoryOverview(
            availableWeeks: intervals,
            overallScore: CompletionScore(
                completedCount: visibleResults.filter(\.isDone).count,
                totalCount: totalCount
            )
        )
    }

    private func fetchHistoryDeletedDayStart(calendar: Calendar) throws -> Date? {
        let key = HistoryState.mainKey
        let descriptor = FetchDescriptor<HistoryState>(
            predicate: #Predicate { $0.key == key }
        )
        return try modelContext.fetch(descriptor).first?.historyDeletedAt.map(calendar.startOfDay(for:))
    }

    private func availableWeekIntervals(
        results: [WeekdayHabitResult],
        currentWeek: DateInterval?,
        calendar: Calendar
    ) -> [DateInterval] {
        var intervalsByStart = results.reduce(into: [Date: DateInterval]()) { intervals, result in
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: result.day) else { return }
            intervals[interval.start] = interval
        }

        if let currentWeek {
            intervalsByStart[currentWeek.start] = currentWeek
        }

        return intervalsByStart.values.sorted { $0.start < $1.start }
    }

    private func taskCount(
        in weekInterval: DateInterval,
        habits: [WeekdayHabit],
        results: [WeekdayHabitResult],
        historyDeletedDayStart: Date?,
        calendar: Calendar
    ) -> Int {
        let habitIDsWithResults = Set(results.map { $0.weekdayHabit.persistentModelID })
        let scheduledCount = habits.reduce(0) { count, habit in
            guard !habitIDsWithResults.contains(habit.persistentModelID) else { return count }
            let scheduledDate = scheduledDate(for: habit, in: weekInterval, calendar: calendar)
            guard isVisible(
                habit: habit,
                scheduledDate: scheduledDate,
                historyDeletedDayStart: historyDeletedDayStart,
                calendar: calendar
            ) else {
                return count
            }
            return count + 1
        }
        return results.count + scheduledCount
    }

    private func scheduledDate(
        for habit: WeekdayHabit,
        in weekInterval: DateInterval,
        calendar: Calendar
    ) -> Date {
        let startWeekday = calendar.component(.weekday, from: weekInterval.start)
        let targetWeekday = calendarWeekday(for: habit.weekday)
        let dayOffset = (targetWeekday - startWeekday + 7) % 7
        let weekdayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start)
            ?? weekInterval.start
        return calendar.date(
            bySettingHour: habit.hour,
            minute: habit.minute,
            second: 0,
            of: weekdayDate
        ) ?? weekdayDate
    }

    private func isVisible(
        habit: WeekdayHabit,
        scheduledDate: Date,
        historyDeletedDayStart: Date?,
        calendar: Calendar
    ) -> Bool {
        if let historyDeletedDayStart, scheduledDate < historyDeletedDayStart {
            return false
        }

        if let deletedAt = habit.deletedAt,
           scheduledDate >= calendar.startOfDay(for: deletedAt) {
            return false
        }

        return habit.createdAt <= scheduledDate
            || calendar.isDate(habit.createdAt, inSameDayAs: scheduledDate)
    }

    private func calendarWeekday(for weekday: Weekday) -> Int {
        switch weekday {
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        case .sunday: 1
        }
    }
}
