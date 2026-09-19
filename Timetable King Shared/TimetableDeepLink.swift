import Foundation

enum TimetableDeepLink {
    enum Destination: Equatable, Sendable {
        case todayTasks
        case weeklySummary
        case task(String)
        case reminder(scheduleID: UUID, taskDate: Date)
    }

    static let scheme = "timetableking"
    static let todayTasksURL = URL(string: "\(scheme)://today-tasks")!
    static let weeklySummaryURL = URL(string: "\(scheme)://weekly-summary")!

    static func taskURL(taskID: String) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "task"
        components.queryItems = [URLQueryItem(name: "id", value: taskID)]
        return components.url!
    }

    static func destination(for url: URL) -> Destination? {
        guard url.scheme == scheme else { return nil }

        switch url.host {
        case "today-tasks":
            return .todayTasks
        case "weekly-summary":
            return .weeklySummary
        case "task":
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let taskID = components.queryItems?.first(where: { $0.name == "id" })?.value else {
                return nil
            }
            return .task(taskID)
        case "reminder":
            guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                  let id = items.first(where: { $0.name == "schedule" })?.value.flatMap(UUID.init(uuidString:)),
                  let timestamp = items.first(where: { $0.name == "date" })?.value.flatMap(TimeInterval.init),
                  timestamp.isFinite else { return nil }
            return .reminder(scheduleID: id, taskDate: Date(timeIntervalSince1970: timestamp))
        default:
            return nil
        }
    }

    static func reminderURL(scheduleID: UUID, taskDate: Date) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "reminder"
        components.queryItems = [
            URLQueryItem(name: "schedule", value: scheduleID.uuidString),
            URLQueryItem(name: "date", value: String(taskDate.timeIntervalSince1970))
        ]
        return components.url!
    }
}
