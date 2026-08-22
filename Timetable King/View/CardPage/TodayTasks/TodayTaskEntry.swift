import Foundation

struct TodayTaskEntry: Identifiable, Hashable {
    let habit: WeekdayHabit
    let result: WeekdayHabitResult?
    let displayStatus: TodayTaskDisplayStatus

    init(
        habit: WeekdayHabit,
        result: WeekdayHabitResult?,
        displayStatus: TodayTaskDisplayStatus? = nil
    ) {
        self.habit = habit
        self.result = result
        self.displayStatus = displayStatus ?? TodayTaskDisplayStatus(resultStatus: result?.status)
    }

    var id: WeekdayHabit {
        habit
    }

    var title: String {
        habit.habit.title
    }

    var timeString: String {
        habit.timeString
    }

    var widgetIdentifier: String {
        TimetableWidgetTask.identifier(
            weekday: habit.weekday.rawValue,
            hour: habit.hour,
            minute: habit.minute,
            title: title
        )
    }

    var statusTitle: String {
        displayStatus.title
    }

    var statusDescription: String {
        switch displayStatus {
        case .done:
            "timetable.today.task.status.description.done".localized
        case .failed:
            "timetable.today.task.status.description.failed".localized
        case .todo:
            "timetable.today.task.status.description.none".localized
        case .future:
            "timetable.today.task.status.description.future".localized
        }
    }

    var detailDescription: String {
        displayStatus.detailDescription(timeString: timeString)
    }
}

enum TodayTaskDisplayStatus: Hashable {
    case done
    case failed
    case todo
    case future

    init(resultStatus: HabitState?) {
        switch resultStatus ?? .none {
        case .done:
            self = .done
        case .failed:
            self = .failed
        case .none:
            self = .todo
        }
    }
}

extension TodayTaskDisplayStatus {
    var title: String {
        switch self {
        case .done:
            "timetable.today.task.status.done".localized
        case .failed:
            "timetable.today.task.status.failed".localized
        case .todo:
            "timetable.today.task.status.none".localized
        case .future:
            "timetable.today.task.status.future".localized
        }
    }

    func detailDescription(timeString: String) -> String {
        switch self {
        case .done:
            "timetable.today.task.detail.description.done".localized(timeString)
        case .failed:
            "timetable.today.task.detail.description.failed".localized(timeString)
        case .todo:
            "timetable.today.task.detail.description.none".localized(timeString)
        case .future:
            "timetable.today.task.detail.description.future".localized(timeString)
        }
    }
}
