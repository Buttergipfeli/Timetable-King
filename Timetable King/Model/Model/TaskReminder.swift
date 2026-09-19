enum TaskReminder: Int, CaseIterable {
    case off = -1
    case atTime = 0
    case tenMinutesBefore = 10

    var minutesBefore: Int? {
        self == .off ? nil : rawValue
    }

    var title: String {
        switch self {
        case .off: "task.reminder.off".localized
        case .atTime: "task.reminder.at.time".localized
        case .tenMinutesBefore: "task.reminder.ten.minutes".localized
        }
    }
}
