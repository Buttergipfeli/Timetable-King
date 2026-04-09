import Foundation
import SwiftData

@Model
final class HistoryState {
    static let mainKey = "main"

    #Unique<HistoryState>([\.key])

    var historyDeletedAt: Date?

    private(set) var key: String

    init(historyDeletedAt: Date? = nil) {
        self.historyDeletedAt = historyDeletedAt
        self.key = Self.mainKey
    }
}
