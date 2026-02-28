import Foundation

struct TodayTaskEntry: Identifiable {
    enum State {
        case done
        case failed
        case undefined
    }

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
        switch state {
        case .done:
            "Finished"
        case .failed:
            "Not done"
        case .undefined:
            "Undefined"
        }
    }

    var statusDescription: String {
        switch state {
        case .done:
            "This task has been completed."
        case .failed:
            "This task was marked as not completed."
        case .undefined:
            "This task does not have a defined result yet."
        }
    }

    var detailDescription: String {
        switch state {
        case .done:
            "Scheduled at \(timeString). This task is already finished."
        case .failed:
            "Scheduled at \(timeString). This task has a defined result and is marked as not done."
        case .undefined:
            "Scheduled at \(timeString). This task does not have a status yet."
        }
    }

    var state: State {
        switch result?.status {
        case .done?:
            .done
        case .failed?:
            .failed
        case nil:
            .undefined
        }
    }
}
