import Foundation

struct WeekdayHabitableComparator<Habitable: WeekdayHabitable>: SortComparator {
    var order: SortOrder = .forward
    
    func compare(_ lhs: Habitable, _ rhs: Habitable) -> ComparisonResult {
        let result: ComparisonResult
        
        if lhs.weekdayHabit.weekday != rhs.weekdayHabit.weekday {
            result = lhs.weekdayHabit.weekday.sortIndex < rhs.weekdayHabit.weekday.sortIndex ? .orderedAscending : .orderedDescending
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
