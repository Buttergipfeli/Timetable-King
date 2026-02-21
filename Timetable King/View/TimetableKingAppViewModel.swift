import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let modelContainerService: ModelContainerService
    
    private(set) var entries: [WeekdayHabit] = []
    
    init(modelContainerService: ModelContainerService) {
        self.modelContainerService = modelContainerService
        load()
    }

    func load() {
        guard let habits = try? modelContainerService.context.fetch(FetchDescriptor<WeekdayHabit>()) else { return }
        
        entries = habits.sorted { lhs, rhs in
            if lhs.weekday.sortIndex == rhs.weekday.sortIndex {
                return lhs.timeString < rhs.timeString
            }
            return lhs.weekday.sortIndex < rhs.weekday.sortIndex
        }
    }
}
