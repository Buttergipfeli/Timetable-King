import Foundation

@MainActor
@Observable
final class TodayTasksViewModel {
    private(set) var finishedHabits = [WeekdayHabit]()
    private(set) var finishedResults = [WeekdayHabitResult?]()
    private(set) var unfinishedHabits = [WeekdayHabit]()
    
    func map(todayDigest: WeekdayDigest?) {
        guard let todayDigest else { return }
        var mappedResultsToHabits = todayDigest.habits.map { habit in
            todayDigest.results.first { $0.weekdayHabit == habit }
        }
        let finishedUnfinishedIndexes = mappedResultsToHabits.partition { $0?.isDone == true }
        
        finishedHabits = Array(todayDigest.habits[finishedUnfinishedIndexes...])
        finishedResults = Array(mappedResultsToHabits[finishedUnfinishedIndexes...])
        
        unfinishedHabits = Array(todayDigest.habits[..<finishedUnfinishedIndexes])
    }
}
