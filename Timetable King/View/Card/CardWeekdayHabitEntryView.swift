import SwiftUI

struct CardWeekdayHabitEntryView: View {
    let weekdayHabit: WeekdayHabit
    
    var body: some View {
        CardEntryView {
            Text(weekdayHabit.timeString)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.primary)
                .padding(.horizontal, .entryTimeHorizontalPadding)
                .padding(.vertical, .entryTimeVerticalPadding)
                .background(.thinMaterial, in: Capsule())
            
            Divider()
                        
            Text(weekdayHabit.habit.title)
                .foregroundStyle(.primary)
        }
    }
}

private extension CGFloat {
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
}
