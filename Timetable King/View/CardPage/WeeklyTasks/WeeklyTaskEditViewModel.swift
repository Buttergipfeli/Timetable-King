import Foundation

@Observable
final class WeeklyTaskEditViewModel {
    var title = ""
    var weekdays: Set<Weekday> = [.current]
    var time = Date.now
    var reminder: TaskReminder = .off

    var isSaveable: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !weekdays.isEmpty
    }

    func setup(habit: WeekdayHabit) {
        title = habit.habit.title
        reminder = habit.reminder
        weekdays = Set(habit.activeRecurrenceSchedules.map(\.weekday))
        var components = DateComponents()
        components.hour = habit.hour
        components.minute = habit.minute
        time = Calendar.current.date(from: components) ?? .now
    }

    func save(
        habit: WeekdayHabit,
        onSave: (WeekdayHabit, String, Set<Weekday>, Int, Int, TaskReminder) -> Bool
    ) -> Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        return onSave(
            habit,
            title.trimmingCharacters(in: .whitespacesAndNewlines),
            weekdays,
            components.hour ?? 0,
            components.minute ?? 0,
            reminder
        )
    }
}
