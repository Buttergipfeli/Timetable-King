import Foundation
import SwiftData

final class WeekdayDigestService {
    private let modelContainerService: ModelContainerService

    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
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

        let habitIDsWithResults = Set(fetchedResults.map { $0.weekdayHabit.persistentModelID })

        let filteredHabits = allHabits.filter { habit in
            if habitIDsWithResults.contains(habit.persistentModelID) { return true }
            guard !habit.isDeleted else { return false }
            let scheduled = scheduledDate(for: habit, in: weekInterval)
            return habit.createdAt <= scheduled || isCreatedOnScheduledDay(for: habit, scheduledDate: scheduled)
        }

        let futureHabits = allHabits.filter { habit in
            guard !habitIDsWithResults.contains(habit.persistentModelID),
                  !habit.isDeleted else { return false }

            let scheduled = scheduledDate(for: habit, in: weekInterval)
            return habit.createdAt > scheduled &&
                   habit.createdAt < weekInterval.end &&
                   !isCreatedOnScheduledDay(for: habit, scheduledDate: scheduled)
        }

        let habitBuckets = groupByWeekday(items: filteredHabits)
        let resultBuckets = groupResultsByDay(fetchedResults)
        let futureHabitBuckets = groupByWeekday(items: futureHabits)

        return WeekdayDigestBuilder(
            habits: habitBuckets,
            results: resultBuckets,
            futureHabits: futureHabitBuckets
        )
        .build()
    }

    func fetchAvailableWeekIntervals() -> [DateInterval] {
        let results = (try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabitResult>())) ?? []
        var seen = Set<Date>()
        var intervals: [DateInterval] = []

        for result in results {
            guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: result.day) else { continue }
            if seen.insert(interval.start).inserted {
                intervals.append(interval)
            }
        }

        let currentInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date())!
        if !seen.contains(currentInterval.start) {
            intervals.append(currentInterval)
        }

        return intervals.sorted { $0.start > $1.start }
    }

    private func scheduledDate(for habit: WeekdayHabit, in weekInterval: DateInterval) -> Date {
        let dayOffset = habit.weekday.sortIndex - 1
        let weekdayDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekInterval.start) ?? weekInterval.start
        return Calendar.current.date(bySettingHour: habit.hour, minute: habit.minute, second: 0, of: weekdayDate) ?? weekdayDate
    }

    private func isCreatedOnScheduledDay(for habit: WeekdayHabit, scheduledDate: Date) -> Bool {
        Calendar.current.isDate(habit.createdAt, inSameDayAs: scheduledDate)
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
                let weekday = weekday(for: item.day)
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

    private func weekday(for date: Date) -> Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)

        return switch weekdayNumber {
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        case 7: .saturday
        case 1: .sunday
        default: .monday
        }
    }
}
