import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel: ModelContextInjectable {
    private(set) var entries: [WeekdayHabit] = []

    override func refresh() {
        guard let modelContext, let habits = try? modelContext.fetch(FetchDescriptor<WeekdayHabit>()) else { return }
        
        entries = habits.sorted { lhs, rhs in
            if lhs.weekday.sortIndex == rhs.weekday.sortIndex {
                return lhs.timeString < rhs.timeString
            }
            return lhs.weekday.sortIndex < rhs.weekday.sortIndex
        }
    }
}
