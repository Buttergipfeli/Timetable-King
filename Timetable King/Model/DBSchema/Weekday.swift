import SwiftData

@Model
final class Weekday {
    #Unique<Weekday>([\.name])
    var name: String

    @Relationship(deleteRule: .cascade, inverse: \WeekdayHabit.weekday)
    var habits: [WeekdayHabit] = []

    init(name: String) {
        self.name = name
    }
}
