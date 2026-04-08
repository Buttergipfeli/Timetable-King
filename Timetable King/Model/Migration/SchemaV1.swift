import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Habit.self, WeekdayHabit.self, WeekdayHabitResult.self]
    }
}
