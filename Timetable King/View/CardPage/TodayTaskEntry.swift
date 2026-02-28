import Foundation

struct TodayTaskEntry: Identifiable {
    let habit: WeekdayHabit
    let result: WeekdayHabitResult?

    var id: WeekdayHabit {
        habit
    }

    var title: String {
        habit.habit.title
    }

    var timeString: String {
        habit.timeString
    }

    var statusTitle: String {
        switch status {
        case .done:
            "Finished"
        case .failed:
            "Not done"
        case .none:
            "Undefined"
        }
    }

    var statusDescription: String {
        switch status {
        case .done:
            "This task has been completed."
        case .failed:
            "This task was marked as not completed."
        case .none:
            "This task does not have a defined result yet."
        }
    }

    var detailDescription: String {
        switch status {
        case .done:
            "Scheduled at \(timeString). This task is already finished."
        case .failed:
            "Scheduled at \(timeString). This task has a defined result and is marked as not done."
        case .none:
            "Scheduled at \(timeString). This task does not have a status yet."
        }
    }

    var status: HabitState {
        result?.status ?? .none
    }
}
