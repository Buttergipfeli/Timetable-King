import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let weekdayDigestService: WeekdayDigestService
    
    private(set) var weekdayDigests = [WeekdayDigest]()
    
    var activeWeekdayDigests: [WeekdayDigest] {
        weekdayDigests.filter(\.habits.isEmpty.not)
    }
    
    var todayHabits: [WeekdayHabit] {
        weekdayDigests.first(where: \.weekday.isToday)?.habits ?? []
    }
    
    init(modelContainerService: ModelContainerService) {
        weekdayDigestService = WeekdayDigestService(modelContainerService: modelContainerService)
    }

    func load() {
        guard let fetchedDigests = weekdayDigestService.fetchWeekdayDigests() else { return }
        weekdayDigests = fetchedDigests
    }
}
