import Foundation

struct TodayTaskReviewSession: Identifiable, Hashable {
    let id = UUID()
    let entries: [TodayTaskReviewEntry]
}
