import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel: ModelContextInjectable {
    private(set) var entries: [WeekdayHabit] = []

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
        
        entries = habits.sorted { lhs, rhs in
            if lhs.weekday.sortIndex == rhs.weekday.sortIndex {
                return lhs.timeString < rhs.timeString
            }
            return lhs.weekday.sortIndex < rhs.weekday.sortIndex
        }
    }
}
