import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let weekdayDigestService: WeekdayDigestService
    
    private(set) var weekdayDigests = [WeekdayDigest]()
    private(set) var presentedCard: CardPage?
    var isCardPresented: Bool = false
    
    var activeWeekdayDigests: [WeekdayDigest] {
        weekdayDigests.filter(\.habits.isEmpty.not)
    }
    
    var todayDigest: WeekdayDigest? {
        weekdayDigests.first(where: \.weekday.isToday)
    }
    
    init(modelContainerService: ModelContainerService) {
        weekdayDigestService = WeekdayDigestService(modelContainerService: modelContainerService)
    }

    func load() {
        guard let fetchedDigests = weekdayDigestService.fetchWeekdayDigests() else { return }
        weekdayDigests = fetchedDigests
    }
    
    func open(card: CardPage) {
        presentedCard = card
        isCardPresented = true
    }
}
