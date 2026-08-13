import Foundation

enum Weekday: String, Codable, CaseIterable, Sendable {
    static var current: Weekday {
        Weekday(date: .now)
    }

    init(date: Date) {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)

        self = switch weekdayNumber {
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        case 7: .saturday
        case 1: .sunday
        default: .monday
        }
    }
    
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var isToday: Bool {
        self == .current
    }

    var isFuture: Bool {
        sortIndex > Weekday.current.sortIndex
    }
    
    var sortIndex: Int {
        switch self {
        case .monday: 1
        case .tuesday: 2
        case .wednesday: 3
        case .thursday: 4
        case .friday: 5
        case .saturday: 6
        case .sunday: 7
        }
    }

    func dayOffset(from startWeekday: Weekday) -> Int {
        (sortIndex - startWeekday.sortIndex + Weekday.allCases.count) % Weekday.allCases.count
    }
    
    var label: String {
        "weekday.\(rawValue)".localized
    }

    var shortLabel: String {
        "weekday.\(rawValue).short".localized
    }
}
