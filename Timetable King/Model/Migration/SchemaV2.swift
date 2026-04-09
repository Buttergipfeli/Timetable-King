import SwiftData

enum SchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Habit.self, WeekdayHabit.self, WeekdayHabitResult.self, HistoryState.self]
    }
}
