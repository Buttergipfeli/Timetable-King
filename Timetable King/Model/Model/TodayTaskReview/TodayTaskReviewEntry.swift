import Foundation
import SwiftData

struct TodayTaskReviewEntry: Identifiable, Hashable {
    let habit: WeekdayHabit
    let day: Date
    let scheduledDate: Date

    var id: String {
        "\(habit.persistentModelID)-\(day.timeIntervalSinceReferenceDate)"
    }

    var title: String {
        habit.habit.title
    }

    var timeString: String {
        habit.timeString
    }
}
