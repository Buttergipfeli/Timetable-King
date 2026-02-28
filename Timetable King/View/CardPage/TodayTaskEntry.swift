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
            "timetable.today.task.status.done".localized
        case .failed:
            "timetable.today.task.status.failed".localized
        case .none:
            "timetable.today.task.status.none".localized
        }
    }

    var statusDescription: String {
        switch status {
        case .done:
            "timetable.today.task.status.description.done".localized
        case .failed:
            "timetable.today.task.status.description.failed".localized
        case .none:
            "timetable.today.task.status.description.none".localized
        }
    }

    var detailDescription: String {
        switch status {
        case .done:
            "timetable.today.task.detail.description.done".localized(timeString)
        case .failed:
            "timetable.today.task.detail.description.failed".localized(timeString)
        case .none:
            "timetable.today.task.detail.description.none".localized(timeString)
        }
    }

    var status: HabitState {
        result?.status ?? .none
    }
}
