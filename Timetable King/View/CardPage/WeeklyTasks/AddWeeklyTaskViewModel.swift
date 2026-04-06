import Foundation

@Observable
final class AddWeeklyTaskViewModel {
    var title = ""
    var weekday: Weekday = .current
    var time = Date.now

    var isSaveable: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func setup(preselectedWeekday: Weekday?) {
        weekday = preselectedWeekday ?? .current
    }

    func save(onSave: (String, Weekday, Int, Int) -> Void) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        onSave(title, weekday, components.hour ?? 0, components.minute ?? 0)
    }
}
