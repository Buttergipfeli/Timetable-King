import Foundation
import SwiftData

final class TodayTaskReviewService {
    private let modelContainerService: ModelContainerService
    private let historyStateService: HistoryStateService

    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
        historyStateService = HistoryStateService(modelContainerService: modelContainerService)
    }

    @discardableResult
    func resolvePastUndefinedTasks(referenceDate: Date = .now) throws -> Int {
        let context = modelContainerService.context
        let habits = try context.fetch(FetchDescriptor<WeekdayHabit>())
            .filter { !$0.isDeleted }

        let startOfToday = Calendar.current.startOfDay(for: referenceDate)
        var createdResultsCount = 0

        for habit in habits {
            let scheduledDates = unresolvedPastScheduledDates(for: habit, before: startOfToday)

            for scheduledDate in scheduledDates {
                guard effectiveResult(for: habit, on: scheduledDate) == nil else { continue }
                context.insert(WeekdayHabitResult(day: scheduledDate, weekdayHabit: habit, status: .failed))
                createdResultsCount += 1
            }
        }

        if createdResultsCount > 0 {
            try context.save()
        }

        return createdResultsCount
    }

    func fetchPendingReviewEntries(referenceDate: Date = .now) -> [TodayTaskReviewEntry] {
        let startOfToday = Calendar.current.startOfDay(for: referenceDate)
        let habits = ((try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>())) ?? [])
            .filter { !$0.isDeleted && $0.weekday.isToday }

        return habits
            .compactMap { habit in
                let scheduledDate = scheduledDate(for: habit, on: startOfToday)
                guard isOccurrenceValid(for: habit, scheduledDate: scheduledDate),
                      scheduledDate <= referenceDate,
                      effectiveResult(for: habit, on: startOfToday) == nil else { return nil }

                return TodayTaskReviewEntry(
                    habit: habit,
                    day: startOfToday,
                    scheduledDate: scheduledDate
                )
            }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }

    func setStatus(_ status: HabitState, for entry: TodayTaskReviewEntry) throws {
        try setStatus(status, for: entry.habit, on: entry.day)
    }

    func setStatus(_ status: HabitState, for habit: WeekdayHabit, on day: Date) throws {
        let context = modelContainerService.context
        let normalizedDay = Calendar.current.startOfDay(for: day)

        if status == .none {
            if let result = storedResult(for: habit, on: normalizedDay) {
                context.delete(result)
                try context.save()
            }
            return
        }

        if let result = storedResult(for: habit, on: normalizedDay) {
            result.status = status
        } else {
            context.insert(WeekdayHabitResult(day: normalizedDay, weekdayHabit: habit, status: status))
        }

        try context.save()
    }

    private func unresolvedPastScheduledDates(for habit: WeekdayHabit, before date: Date) -> [Date] {
        guard let createdWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: habit.createdAt)?.start else {
            return []
        }

        var scheduledDate = scheduledDate(for: habit, inWeekStartingAt: createdWeekStart)
        if isOccurrenceValid(for: habit, scheduledDate: scheduledDate).not {
            scheduledDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: scheduledDate) ?? scheduledDate
        }

        var scheduledDates = [Date]()

        while scheduledDate < date {
            if isVisibleAfterHistoryReset(scheduledDate) {
                scheduledDates.append(scheduledDate)
            }
            scheduledDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: scheduledDate) ?? scheduledDate
        }

        return scheduledDates
    }

    private func storedResult(for habit: WeekdayHabit, on day: Date) -> WeekdayHabitResult? {
        let normalizedDay = Calendar.current.startOfDay(for: day)
        return habit.results.first { Calendar.current.isDate($0.day, inSameDayAs: normalizedDay) }
    }

    private func effectiveResult(for habit: WeekdayHabit, on day: Date) -> WeekdayHabitResult? {
        guard let result = storedResult(for: habit, on: day) else { return nil }
        return result.status == .none ? nil : result
    }

    private func isOccurrenceValid(for habit: WeekdayHabit, scheduledDate: Date) -> Bool {
        habit.createdAt <= scheduledDate || Calendar.current.isDate(habit.createdAt, inSameDayAs: scheduledDate)
    }

    private func scheduledDate(for habit: WeekdayHabit, inWeekStartingAt weekStart: Date) -> Date {
        let dayOffset = habit.weekday.sortIndex - 1
        let weekdayDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
        return scheduledDate(for: habit, on: weekdayDate)
    }

    private func scheduledDate(for habit: WeekdayHabit, on day: Date) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: day)
        return Calendar.current.date(bySettingHour: habit.hour, minute: habit.minute, second: 0, of: startOfDay) ?? startOfDay
    }

    private func isVisibleAfterHistoryReset(_ date: Date) -> Bool {
        guard let resetDayStart = historyStateService.historyDeletedDayStart else { return true }
        return date >= resetDayStart
    }
}
