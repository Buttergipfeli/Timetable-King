import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel: ModelContextInjectable {
    struct TimetableEntry: Identifiable {
        let id: PersistentIdentifier
        let title: String
        let weekdayLabel: String
        let time: String
        let weekdaySortIndex: Int
    }

    private(set) var entries: [TimetableEntry] = []

    @ObservationIgnored private var modelContext: ModelContext?

    func injectModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func refresh() {
        guard let modelContext else { return }
        refresh(from: modelContext)
    }

    private func refresh(from context: ModelContext) {
        guard let habits = try? context.fetch(FetchDescriptor<WeekdayHabit>()) else { return }
        
        entries = habits
            .map { habit in
                TimetableEntry(
                    id: habit.persistentModelID,
                    title: habit.habit.title,
                    weekdayLabel: Self.weekdayLabel(for: habit.weekday),
                    time: habit.timeString,
                    weekdaySortIndex: Self.weekdaySortIndex(for: habit.weekday)
                )
            }
            .sorted { lhs, rhs in
                if lhs.weekdaySortIndex == rhs.weekdaySortIndex {
                    return lhs.time < rhs.time
                }
                return lhs.weekdaySortIndex < rhs.weekdaySortIndex
            }
    }

    private static func weekdaySortIndex(for weekday: Weekday) -> Int {
        switch weekday {
        case .monday: 1
        case .tuesday: 2
        case .wednesday: 3
        case .thursday: 4
        case .friday: 5
        case .saturday: 6
        case .sunday: 7
        }
    }

    private static func weekdayLabel(for weekday: Weekday) -> String {
        switch weekday {
        case .monday: "Mo"
        case .tuesday: "Di"
        case .wednesday: "Mi"
        case .thursday: "Do"
        case .friday: "Fr"
        case .saturday: "Sa"
        case .sunday: "So"
        }
    }
}
