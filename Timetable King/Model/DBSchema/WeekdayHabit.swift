import SwiftData
import Foundation

@Model
final class WeekdayHabit {
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

    var createdAt: Date = Date.now
    var deletedAt: Date?
    var recurrenceID: UUID?

    @Transient
    var isDeleted: Bool {
        deletedAt != nil
    }

    @Relationship(deleteRule: .cascade, inverse: \WeekdayHabitResult.weekdayHabit)
    var results: [WeekdayHabitResult] = []

    init(
        hour: Int,
        minute: Int,
        weekdayRawValue: String,
        habit: Habit,
        recurrenceID: UUID? = nil
    ) {
        self.hour = hour
        self.minute = minute
        self.weekdayRawValue = weekdayRawValue
        self.habit = habit
        self.recurrenceID = recurrenceID
    }

    var activeRecurrenceSchedules: [WeekdayHabit] {
        guard let recurrenceID else { return isDeleted ? [] : [self] }
        return habit.weekdayHabits.filter {
            !$0.isDeleted && $0.recurrenceID == recurrenceID
        }
    }

    @Transient
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
}

extension WeekdayHabit: WeekdayHabitable {
    var weekdayHabit: WeekdayHabit {
        self
    }
}
