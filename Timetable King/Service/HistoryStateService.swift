import Foundation
import SwiftData

final class HistoryStateService {
    var historyDeletedAt: Date? {
        try? fetchState()?.historyDeletedAt
    }

    var historyDeletedDayStart: Date? {
        guard let historyDeletedAt else { return nil }
        return calendar.startOfDay(for: historyDeletedAt)
    }

    var historyDeletedWeekStart: Date? {
        guard let historyDeletedAt else { return nil }
        return calendar.dateInterval(of: .weekOfYear, for: historyDeletedAt)?.start
    }

    private let modelContainerService: ModelContainerService
    private let calendar: Calendar

    init(
        modelContainerService: ModelContainerService,
        calendar: Calendar = .current
    ) {
        self.modelContainerService = modelContainerService
        self.calendar = calendar
    }

    func markHistoryDeleted(at date: Date = .now) throws {
        let state = try fetchOrCreateState()
        state.historyDeletedAt = date
        try modelContainerService.context.save()
    }

    private func fetchState() throws -> HistoryState? {
        let mainKey = HistoryState.mainKey
        let descriptor = FetchDescriptor<HistoryState>(
            predicate: #Predicate { $0.key == mainKey }
        )
        return try modelContainerService.context.fetch(descriptor).first
    }

    private func fetchOrCreateState() throws -> HistoryState {
        if let state = try fetchState() {
            return state
        }

        let state = HistoryState()
        modelContainerService.context.insert(state)
        return state
    }
}
