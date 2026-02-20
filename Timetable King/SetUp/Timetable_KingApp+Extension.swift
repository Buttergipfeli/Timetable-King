import SwiftData

extension Timetable_KingApp {
    static func setUpModelContainer() -> ModelContainer {
        let schema = Schema([
            Item.self,
            Habit.self,
            WeekdayHabit.self,
            WeekdayHabitResult.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
