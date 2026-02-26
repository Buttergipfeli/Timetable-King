import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let modelContainerService: ModelContainerService
    
    private(set) var weekdayDigests = [WeekdayDigest]()
    
    var activeWeekdayDigests: [WeekdayDigest] {
        weekdayDigests.filter(\.habits.isEmpty.not)
    }
    
    var todayHabits: [WeekdayHabit] {
        weekdayDigests.first(where: \.weekday.isToday)?.habits ?? []
    }
    
    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
    }

    func load() {
        guard let fetchedHabits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()),
              let fetchedResults = fetchWeekdayHabitResultsForCurrentWeek() else { return }
        
        let habitBuckets = groupByWeekday(items: fetchedHabits)
        let resultBuckets = groupByWeekday(items: fetchedResults)
        
        weekdayDigests = WeekdayDigestBuilder(
            habits: habitBuckets,
            results: resultBuckets
        ).build()
    }

    private func groupByWeekday<Item: WeekdayHabitable>(
        items: [Item]
    ) -> [WeekdayBucket<Item>] {
        items
            .sorted(using: WeekdayHabitableComparator())
            .reduce([WeekdayBucket]()) { buckets, item in
                var nextBuckets = buckets
                let lastBucket = buckets.last
                
                if lastBucket?.weekday == item.weekdayHabit.weekday {
                    let lastIndex = nextBuckets.count - 1
                    nextBuckets[lastIndex] = nextBuckets[lastIndex].appending(item)
                } else {
                    let newBucket = WeekdayBucket(weekday: item.weekdayHabit.weekday, items: [item])
                    nextBuckets.append(newBucket)
                }
                
                return nextBuckets
            }
    }
    
    private func fetchWeekdayHabitResultsForCurrentWeek() -> [WeekdayHabitResult]? {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return nil }
        let weekStart = weekInterval.start
        let nextWeekStart = weekInterval.end
        
        let descriptor = FetchDescriptor<WeekdayHabitResult>(
            predicate: #Predicate<WeekdayHabitResult> { result in
                result.day >= weekStart && result.day < nextWeekStart
            }
        )
        
        return try? modelContainerService.context.fetch(descriptor)
    }
}
