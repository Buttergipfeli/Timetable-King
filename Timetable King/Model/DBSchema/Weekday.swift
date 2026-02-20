import Foundation

enum Weekday: String, Codable, CaseIterable, Sendable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
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
    
    var shortLabel: String {
        "weekday.\(rawValue).short".localized
    }
}
