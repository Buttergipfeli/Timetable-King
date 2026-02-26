import SwiftUI

struct CardWeekdayHabitResultsView: View {
    let weekdayDigest: WeekdayDigest
    
    private var completedResultsCount: Int {
        weekdayDigest.results.count(where: \.isDone)
    }
    
    var body: some View {
        CardEntryView {
            Text(weekdayDigest.weekday.shortLabel)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.primary)
                .padding(.horizontal, .entryTimeHorizontalPadding)
                .padding(.vertical, .entryTimeVerticalPadding)
                .background(.thinMaterial, in: Capsule())
            
            Divider()
            
            Text("timetable.weekday.results.done".localized(completedResultsCount, weekdayDigest.habits.count))
                .foregroundStyle(.primary)
        }
    }
}

private extension CGFloat {
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
}
