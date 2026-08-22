import Foundation
import SwiftData

final class WeekdayDigestService {
    private let modelContainerService: ModelContainerService
    private let historyStateService: HistoryStateService

    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
        historyStateService = HistoryStateService(modelContainerService: modelContainerService)
    }

    func fetchWeekdayDigests() -> [WeekdayDigest]? {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return nil }
        return fetchWeekdayDigests(for: weekInterval)
    }

    func fetchWeeklyTaskDigests() -> [WeekdayDigest]? {
        guard let allHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()) else { return nil }

        let activeHabits = allHabits.filter { !$0.isDeleted }
        let habitBuckets = groupByWeekday(items: activeHabits)

        return WeekdayDigestBuilder(habits: habitBuckets, results: [], futureHabits: []).build()
    }

    func fetchWeekdayDigests(for weekInterval: DateInterval) -> [WeekdayDigest]? {
        guard let allHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()),
              let fetchedResults = fetchResults(for: weekInterval) else { return nil }

        return buildWeekdayDigests(
            for: weekInterval,
            allHabits: allHabits,
            fetchedResults: fetchedResults
        )
    }

    func fetchOverallCompletionScore(for weekIntervals: [DateInterval]) -> CompletionScore? {
        guard let allHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()),
              let allResults = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabitResult>()) else {
            return nil
        }

        let resultsByWeekStart = allResults.reduce(into: [Date: [WeekdayHabitResult]]()) { result, item in
            guard let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: item.day)?.start else { return }
            result[weekStart, default: []].append(item)
        }

        return weekIntervals.reduce(CompletionScore(completedCount: 0, totalCount: 0)) { score, weekInterval in
            let digests = buildWeekdayDigests(
                for: weekInterval,
                allHabits: allHabits,
                fetchedResults: resultsByWeekStart[weekInterval.start] ?? []
            )
            return CompletionScore(
                completedCount: score.completedCount + digests.flatMap(\.results).filter(\.isDone).count,
                totalCount: score.totalCount + digests.reduce(0) { $0 + $1.habits.count }
            )
        }
    }

    private func buildWeekdayDigests(
        for weekInterval: DateInterval,
        allHabits: [WeekdayHabit],
        fetchedResults: [WeekdayHabitResult]
    ) -> [WeekdayDigest] {
        let visibleResults = fetchedResults.filter { result in
            isVisibleResultAfterHistoryReset(result)
        }

        let habitIDsWithResults = Set(visibleResults.map { $0.weekdayHabit.persistentModelID })

        let scheduledHabits = allHabits.filter { habit in
            guard !habitIDsWithResults.contains(habit.persistentModelID) else { return false }
            let scheduled = scheduledDate(for: habit, in: weekInterval)
            guard isVisibleAfterHistoryReset(scheduled) else { return false }
            guard isBeforeDeletion(scheduled, for: habit) else { return false }
            return habit.createdAt <= scheduled || isCreatedOnScheduledDay(for: habit, scheduledDate: scheduled)
        }

        let futureHabits = allHabits.filter { habit in
            guard !habitIDsWithResults.contains(habit.persistentModelID),
                  !habit.isDeleted else { return false }

            let scheduled = scheduledDate(for: habit, in: weekInterval)
            guard isVisibleAfterHistoryReset(scheduled) else { return false }
            return habit.createdAt > scheduled &&
                   habit.createdAt < weekInterval.end &&
                   !isCreatedOnScheduledDay(for: habit, scheduledDate: scheduled)
        }

        let resultBuckets = groupResultsByDay(visibleResults)
        let habitBuckets = buildHabitBuckets(scheduledHabits: scheduledHabits, resultBuckets: resultBuckets)
        let futureHabitBuckets = groupByWeekday(items: futureHabits)

        return WeekdayDigestBuilder(
            habits: habitBuckets,
            results: resultBuckets,
            futureHabits: futureHabitBuckets
        )
        .build()
    }

    func fetchAvailableWeekIntervals() -> [DateInterval] {
        let results = ((try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabitResult>())) ?? [])
            .filter(isVisibleResultAfterHistoryReset)
        var seen = Set<Date>()
        var intervals: [DateInterval] = []

        for result in results {
            guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: result.day) else { continue }
            if seen.insert(interval.start).inserted {
                intervals.append(interval)
            }
        }

        if let currentInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()),
           !seen.contains(currentInterval.start) {
            intervals.append(currentInterval)
        }

        return intervals.sorted { $0.start > $1.start }
    }

    private func scheduledDate(for habit: WeekdayHabit, in weekInterval: DateInterval) -> Date {
        let dayOffset = habit.weekday.dayOffset(from: Weekday(date: weekInterval.start))
        let weekdayDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekInterval.start) ?? weekInterval.start
        return Calendar.current.date(bySettingHour: habit.hour, minute: habit.minute, second: 0, of: weekdayDate) ?? weekdayDate
    }

    private func isCreatedOnScheduledDay(for habit: WeekdayHabit, scheduledDate: Date) -> Bool {
        Calendar.current.isDate(habit.createdAt, inSameDayAs: scheduledDate)
    }

    private func isBeforeDeletion(_ scheduledDate: Date, for habit: WeekdayHabit) -> Bool {
        guard let deletedAt = habit.deletedAt else { return true }
        return scheduledDate < Calendar.current.startOfDay(for: deletedAt)
    }

    private func fetchResults(for weekInterval: DateInterval) -> [WeekdayHabitResult]? {
        let weekStart = weekInterval.start
        let weekEnd = weekInterval.end
        let descriptor = FetchDescriptor<WeekdayHabitResult>(
            predicate: #Predicate<WeekdayHabitResult> { result in
                result.day >= weekStart && result.day < weekEnd
            }
        )
        return try? modelContainerService.context.fetch(descriptor)
    }

    private func groupByWeekday<Item: WeekdayHabitable>(items: [Item]) -> [WeekdayBucket<Item>] {
        items
            .sorted(using: WeekdayHabitableComparator())
            .reduce([WeekdayBucket]()) { buckets, item in
                var nextBuckets = buckets
                let lastBucket = buckets.last
                if lastBucket?.weekday == item.weekdayHabit.weekday {
                    let lastIndex = nextBuckets.count - 1
                    nextBuckets[lastIndex] = nextBuckets[lastIndex].appending(item)
                } else {
                    nextBuckets.append(WeekdayBucket(weekday: item.weekdayHabit.weekday, items: [item]))
                }
                return nextBuckets
            }
    }

    private func groupResultsByDay(_ items: [WeekdayHabitResult]) -> [WeekdayBucket<WeekdayHabitResult>] {
        items
            .sorted { lhs, rhs in
                if lhs.day != rhs.day { return lhs.day < rhs.day }
                if lhs.weekdayHabit.hour != rhs.weekdayHabit.hour { return lhs.weekdayHabit.hour < rhs.weekdayHabit.hour }
                if lhs.weekdayHabit.minute != rhs.weekdayHabit.minute { return lhs.weekdayHabit.minute < rhs.weekdayHabit.minute }
                return lhs.weekdayHabit.habit.title < rhs.weekdayHabit.habit.title
            }
            .reduce([WeekdayBucket<WeekdayHabitResult>]()) { buckets, item in
                var nextBuckets = buckets
                let weekday = Weekday(date: item.day)
                let lastBucket = buckets.last

                if lastBucket?.weekday == weekday {
                    let lastIndex = nextBuckets.count - 1
                    nextBuckets[lastIndex] = nextBuckets[lastIndex].appending(item)
                } else {
                    nextBuckets.append(WeekdayBucket(weekday: weekday, items: [item]))
                }

                return nextBuckets
            }
    }

    private func buildHabitBuckets(
        scheduledHabits: [WeekdayHabit],
        resultBuckets: [WeekdayBucket<WeekdayHabitResult>]
    ) -> [WeekdayBucket<WeekdayHabit>] {
        let scheduledBuckets = groupByWeekday(items: scheduledHabits)

        return Weekday.allCases.compactMap { weekday in
            let scheduled = scheduledBuckets.first { $0.weekday == weekday }?.items ?? []
            let historical = resultBuckets.first { $0.weekday == weekday }?.items.map(\.weekdayHabit) ?? []
            let habits = (historical + scheduled).sorted { lhs, rhs in
                if lhs.hour != rhs.hour { return lhs.hour < rhs.hour }
                if lhs.minute != rhs.minute { return lhs.minute < rhs.minute }
                return lhs.habit.title < rhs.habit.title
            }

            return habits.isEmpty ? nil : WeekdayBucket(weekday: weekday, items: habits)
        }
    }

    private func isVisibleResultAfterHistoryReset(_ result: WeekdayHabitResult) -> Bool {
        guard let historyDeletedDayStart = historyStateService.historyDeletedDayStart else { return true }
        return result.day >= historyDeletedDayStart
    }

    private func isVisibleAfterHistoryReset(_ date: Date) -> Bool {
        guard let historyDeletedDayStart = historyStateService.historyDeletedDayStart else { return true }
        return date >= historyDeletedDayStart
    }
}
