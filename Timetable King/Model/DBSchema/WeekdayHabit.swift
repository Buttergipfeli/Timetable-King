import SwiftData
import Foundation

@Model
final class WeekdayHabit {
    #Unique<WeekdayHabit>([\.weekdayRawValue, \.habit, \.hour, \.minute])
    
    var hour: Int
    var minute: Int

    var habit: Habit
    
    private var weekdayRawValue: String
    var weekday: Weekday {
        get {
            Weekday(rawValue: weekdayRawValue) ?? .monday
        }
        set {
            weekdayRawValue = newValue.rawValue
        }
    }

    @Relationship(deleteRule: .cascade, inverse: \WeekdayHabitResult.weekdayHabit)
    var results: [WeekdayHabitResult] = []

    init(hour: Int, minute: Int, weekdayRawValue: String, habit: Habit) {
        self.hour = hour
        self.minute = minute
        self.weekdayRawValue = weekdayRawValue
        self.habit = habit
    }

    @Transient
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
}
