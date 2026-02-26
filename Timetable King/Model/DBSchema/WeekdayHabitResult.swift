import Foundation
import SwiftData

@Model
final class WeekdayHabitResult {
    #Unique<WeekdayHabitResult>([\.day, \.weekdayHabit])
    
    var day: Date
    var weekdayHabit: WeekdayHabit
    var status: Status = Status.none

    init(day: Date, weekdayHabit: WeekdayHabit, status: Status = .none) {
        self.day = Calendar.current.startOfDay(for: day)
        self.weekdayHabit = weekdayHabit
        self.status = status
    }

    @Transient
    var isDone: Bool {
        status == .done
    }
}

extension WeekdayHabitResult: WeekdayHabitable { }
