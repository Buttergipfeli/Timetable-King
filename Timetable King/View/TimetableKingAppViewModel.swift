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
                    weekdayLabel: habit.weekday.weekdayLabel,
                    time: habit.timeString,
                    weekdaySortIndex: habit.weekday.weekdaySortIndex
                )
            }
            .sorted { lhs, rhs in
                if lhs.weekdaySortIndex == rhs.weekdaySortIndex {
                    return lhs.time < rhs.time
                }
                return lhs.weekdaySortIndex < rhs.weekdaySortIndex
            }
    }
}
