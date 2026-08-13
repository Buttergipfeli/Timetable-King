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

            VStack(alignment: .leading, spacing: .contentSpacing) {
                Text("timetable.weekday.results.done".localized(completedResultsCount, weekdayDigest.habits.count))
                    .foregroundStyle(.primary)

                if weekdayDigest.futureHabits.isEmpty.not {
                    Text("timetable.weekly.summary.future.count".localized(weekdayDigest.futureHabits.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(weekdayDigest.performanceEmoji)
        }
    }
}

private extension CGFloat {
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
    static let contentSpacing = 2.0
}
