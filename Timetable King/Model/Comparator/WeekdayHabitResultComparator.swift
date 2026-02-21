import Foundation

struct WeekdayHabitResultComparator: SortComparator {
    var order: SortOrder = .forward
    
    func compare(_ lhs: WeekdayHabitResult, _ rhs: WeekdayHabitResult) -> ComparisonResult {
        let result: ComparisonResult
        
        if lhs.day != rhs.day {
            result = lhs.day < rhs.day ? .orderedAscending : .orderedDescending
        } else if lhs.weekdayHabit.hour != rhs.weekdayHabit.hour {
            result = lhs.weekdayHabit.hour < rhs.weekdayHabit.hour ? .orderedAscending : .orderedDescending
        } else if lhs.weekdayHabit.minute != rhs.weekdayHabit.minute {
            result = lhs.weekdayHabit.minute < rhs.weekdayHabit.minute ? .orderedAscending : .orderedDescending
        } else if lhs.weekdayHabit.habit.title != rhs.weekdayHabit.habit.title {
            result = lhs.weekdayHabit.habit.title < rhs.weekdayHabit.habit.title ? .orderedAscending : .orderedDescending
        } else {
            result = .orderedSame
        }
        
        if order == .reverse {
            switch result {
            case .orderedAscending:
                return .orderedDescending
            case .orderedDescending:
                return .orderedAscending
            case .orderedSame:
                return .orderedSame
            }
        } else {
            return result
        }
    }
}
