import Foundation

@Observable
final class AddWeeklyTaskViewModel {
    var title = ""
    var weekday: Weekday = .current
    var time = Date.now

    var isSaveable: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func setup(preselectedWeekday: Weekday?) {
        weekday = preselectedWeekday ?? .current
    }

    func save(onSave: (String, Weekday, Int, Int) -> Bool) -> Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        return onSave(
            title.trimmingCharacters(in: .whitespacesAndNewlines),
            weekday,
            components.hour ?? 0,
            components.minute ?? 0
        )
    }
}
