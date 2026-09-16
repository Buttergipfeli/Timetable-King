import Foundation

@Observable
final class AddWeeklyTaskViewModel {
    var title = ""
    var weekdays: Set<Weekday> = [.current]
    var time = Date.now

    var isSaveable: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !weekdays.isEmpty
    }

    func setup(preselectedWeekday: Weekday?) {
        weekdays = [preselectedWeekday ?? .current]
    }

    func save(onSave: (String, Set<Weekday>, Int, Int) -> Bool) -> Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        return onSave(
            title.trimmingCharacters(in: .whitespacesAndNewlines),
            weekdays,
            components.hour ?? 0,
            components.minute ?? 0
        )
    }
}
