import Foundation

enum TimetableKingAppGroup {
    static let identifier = "group.ch.ak.Timetable-King"
    static let userDefaults = UserDefaults(suiteName: identifier) ?? .standard
}
