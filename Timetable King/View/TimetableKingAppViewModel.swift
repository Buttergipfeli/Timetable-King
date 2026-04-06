import Foundation
import SwiftData

@MainActor
@Observable
final class TimetableKingAppViewModel {
    private let weekdayDigestService: WeekdayDigestService
    private let weeklyTaskService: WeeklyTaskService

    private(set) var weekdayDigests = [WeekdayDigest]()
    private(set) var presentedCard: CardPage?
    var isCardPresented: Bool = false
    var presentedEntry: TodayTaskEntry?
    var presentedWeekdayDigest: WeekdayDigest?
    
    var activeWeekdayDigests: [WeekdayDigest] {
        weekdayDigests.filter(\.habits.isEmpty.not)
    }
    
    var todayDigest: WeekdayDigest? {
        weekdayDigests.first(where: \.weekday.isToday)
    }
    
    init(modelContainerService: ModelContainerService) {
        weekdayDigestService = WeekdayDigestService(modelContainerService: modelContainerService)
        weeklyTaskService = WeeklyTaskService(modelContainerService: modelContainerService)
    }

    func load() {
        guard let fetchedDigests = weekdayDigestService.fetchWeekdayDigests() else { return }
        weekdayDigests = fetchedDigests
    }
    
    func open(card: CardPage) {
        presentedCard = card
        isCardPresented = true
    }

    func open(habit: WeekdayHabit) {
        guard let digest = todayDigest else { return }
        presentedEntry = TodayTaskEntry(
            habit: habit,
            result: digest.results.first { $0.weekdayHabit == habit }
        )
    }

    func open(weekdayDigest: WeekdayDigest) {
        presentedWeekdayDigest = weekdayDigest
    }

    func addWeeklyTask(title: String, weekday: Weekday, hour: Int, minute: Int) {
        try? weeklyTaskService.save(title: title, weekday: weekday, hour: hour, minute: minute)
        load()
    }
}
