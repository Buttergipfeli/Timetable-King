import Foundation

enum TimetableWidgetConstants {
    static let kind = "TimetableKingWidget"
}

enum TimetableWidgetTaskStatus: String, Codable, Sendable {
    case done
    case failed
    case todo
}

struct TimetableWidgetTask: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let hour: Int
    let minute: Int
    let status: TimetableWidgetTaskStatus

    var timeText: String {
        String(format: "%02d:%02d", hour, minute)
    }

    static func identifier(weekday: String, hour: Int, minute: Int, title: String) -> String {
        "\(weekday)-\(hour)-\(minute)-\(title)"
    }

    func resettingStatus() -> TimetableWidgetTask {
        TimetableWidgetTask(
            id: id,
            title: title,
            hour: hour,
            minute: minute,
            status: .todo
        )
    }
}

struct TimetableWidgetDay: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let weekdayIndex: Int
    let label: String
    let tasks: [TimetableWidgetTask]

    var completedCount: Int {
        tasks.filter { $0.status == .done }.count
    }

    var totalCount: Int {
        tasks.count
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    func resettingStatuses() -> TimetableWidgetDay {
        TimetableWidgetDay(
            id: id,
            weekdayIndex: weekdayIndex,
            label: label,
            tasks: tasks.map { $0.resettingStatus() }
        )
    }
}

struct TimetableWidgetSnapshot: Codable, Equatable, Sendable {
    let generatedAt: Date
    let weekStart: Date
    let week: [TimetableWidgetDay]
    let recurringWeek: [TimetableWidgetDay]

    var todayTasks: [TimetableWidgetTask] {
        today?.tasks ?? []
    }

    var completedTodayCount: Int {
        today?.completedCount ?? 0
    }

    var totalTodayCount: Int {
        today?.totalCount ?? 0
    }

    var weeklyCompletedCount: Int {
        week.reduce(0) { $0 + $1.completedCount }
    }

    var weeklyTotalCount: Int {
        week.reduce(0) { $0 + $1.totalCount }
    }

    var dailyProgress: Double {
        guard totalTodayCount > 0 else { return 0 }
        return Double(completedTodayCount) / Double(totalTodayCount)
    }

    var isTodayComplete: Bool {
        totalTodayCount > 0 && completedTodayCount == totalTodayCount
    }

    var weeklyProgress: Double {
        guard weeklyTotalCount > 0 else { return 0 }
        return Double(weeklyCompletedCount) / Double(weeklyTotalCount)
    }

    var upcomingTasks: [TimetableWidgetTask] {
        todayTasks
            .filter { $0.status == .todo }
            .sorted {
                ($0.hour, $0.minute, $0.title) < ($1.hour, $1.minute, $1.title)
            }
    }

    var nextTask: TimetableWidgetTask? {
        upcomingTasks.first
    }

    func resolved(for date: Date, calendar: Calendar = .current) -> TimetableWidgetSnapshot {
        let targetWeekStart = Self.weekStart(for: date, calendar: calendar)
        let isSameWeek = calendar.isDate(weekStart, inSameDayAs: targetWeekStart)

        return TimetableWidgetSnapshot(
            generatedAt: date,
            weekStart: targetWeekStart,
            week: isSameWeek ? week : recurringWeek,
            recurringWeek: recurringWeek
        )
    }

    static func empty(referenceDate: Date = .now, calendar: Calendar = .current) -> TimetableWidgetSnapshot {
        TimetableWidgetSnapshot(
            generatedAt: referenceDate,
            weekStart: weekStart(for: referenceDate, calendar: calendar),
            week: emptyWeek(calendar: calendar),
            recurringWeek: emptyWeek(calendar: calendar)
        )
    }

    static func placeholder(referenceDate: Date = .now, calendar: Calendar = .current) -> TimetableWidgetSnapshot {
        let currentWeekdayIndex = weekdayIndex(for: referenceDate, calendar: calendar)
        let sampleTasks = [
            TimetableWidgetTask(
                id: "sample-morning-routine",
                title: "Morning routine",
                hour: 8,
                minute: 0,
                status: .done
            ),
            TimetableWidgetTask(
                id: "sample-team-stand-up",
                title: "Team stand-up",
                hour: 10,
                minute: 30,
                status: .todo
            ),
            TimetableWidgetTask(
                id: "sample-deep-work",
                title: "Deep work",
                hour: 14,
                minute: 0,
                status: .todo
            )
        ]
        let week = emptyWeek(calendar: calendar).map { day in
            guard day.weekdayIndex == currentWeekdayIndex else { return day }
            return TimetableWidgetDay(
                id: day.id,
                weekdayIndex: day.weekdayIndex,
                label: day.label,
                tasks: sampleTasks
            )
        }

        return TimetableWidgetSnapshot(
            generatedAt: referenceDate,
            weekStart: weekStart(for: referenceDate, calendar: calendar),
            week: week,
            recurringWeek: week.map { $0.resettingStatuses() }
        )
    }

    static func weekdayIndex(for date: Date, calendar: Calendar = .current) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 ? 7 : weekday - 1
    }

    static func weekStart(for date: Date, calendar: Calendar = .current) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start
            ?? calendar.startOfDay(for: date)
    }

    private var today: TimetableWidgetDay? {
        let index = Self.weekdayIndex(for: generatedAt)
        return week.first { $0.weekdayIndex == index }
    }

    private static func emptyWeek(calendar: Calendar) -> [TimetableWidgetDay] {
        (1...7).map { weekdayIndex in
            TimetableWidgetDay(
                id: String(weekdayIndex),
                weekdayIndex: weekdayIndex,
                label: shortWeekdayLabel(for: weekdayIndex, calendar: calendar),
                tasks: []
            )
        }
    }

    private static func shortWeekdayLabel(for weekdayIndex: Int, calendar: Calendar) -> String {
        let symbolIndex = weekdayIndex == 7 ? 0 : weekdayIndex
        return calendar.shortWeekdaySymbols[symbolIndex]
    }
}

struct TimetableWidgetSnapshotStore {
    private let userDefaults: UserDefaults
    private let key: String

    init(
        userDefaults: UserDefaults = TimetableKingAppGroup.userDefaults,
        key: String = "widget.snapshot"
    ) {
        self.userDefaults = userDefaults
        self.key = key
    }

    func load() -> TimetableWidgetSnapshot? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(TimetableWidgetSnapshot.self, from: data)
    }

    func save(_ snapshot: TimetableWidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        userDefaults.set(data, forKey: key)
    }
}
