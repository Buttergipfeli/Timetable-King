import SwiftUI

struct CardWeeklyTasksEntryView: View {
    let weekday: Weekday
    let tasksForWeekdayCount: Int
    
    var body: some View {
        CardEntryView {
            Text(weekday.shortLabel)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.primary)
                .padding(.horizontal, .entryTimeHorizontalPadding)
                .padding(.vertical, .entryTimeVerticalPadding)
                .background(.thinMaterial, in: Capsule())
            
            Divider()
                        
            Text("\(tasksForWeekdayCount) tasks")
                .foregroundStyle(.primary)
        }
    }
}

private extension CGFloat {
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
}
