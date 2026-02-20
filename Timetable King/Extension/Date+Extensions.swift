import Foundation

extension Date {
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: Date())
    }
}
