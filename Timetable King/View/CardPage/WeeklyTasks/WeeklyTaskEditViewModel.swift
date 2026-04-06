import Foundation

@Observable
final class WeeklyTaskEditViewModel {
    var title = ""
    var weekday: Weekday = .current
    var time = Date.now

    var isSaveable: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func setup(habit: WeekdayHabit) {
        title = habit.habit.title
        weekday = habit.weekday
        var components = DateComponents()
        components.hour = habit.hour
        components.minute = habit.minute
        time = Calendar.current.date(from: components) ?? .now
    }

    func save(habit: WeekdayHabit, onSave: (WeekdayHabit, String, Weekday, Int, Int) -> Void) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        onSave(habit, title, weekday, components.hour ?? 0, components.minute ?? 0)
    }
}
