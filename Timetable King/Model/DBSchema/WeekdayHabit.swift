import SwiftData
import Foundation

@Model
final class WeekdayHabit {
    #Unique<WeekdayHabit>([\.weekday, \.habit, \.hour, \.minute])
    
    var hour: Int
    var minute: Int

    var weekday: Weekday
    var habit: Habit

    @Relationship(deleteRule: .cascade, inverse: \WeekdayHabitResult.weekdayHabit)
    var results: [WeekdayHabitResult] = []

    init(hour: Int, minute: Int, weekday: Weekday, habit: Habit) {
        self.hour = hour
        self.minute = minute
        self.weekday = weekday
        self.habit = habit
    }

    @Transient
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
}
