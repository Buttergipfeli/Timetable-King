import SwiftData

@Model
final class Habit {
    #Unique<Habit>([\.title])

    var title: String

    @Relationship(deleteRule: .cascade, inverse: \WeekdayHabit.habit)
    var weekdayHabits: [WeekdayHabit] = []

    init(title: String) {
        self.title = title
    }
}
