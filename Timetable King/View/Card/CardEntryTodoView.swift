import SwiftUI

struct CardEntryTodoView: View {
    let entry: WeekdayHabitResult
    
    var body: some View {
        HStack(spacing: .entryRowSpacing) {
            Text(entry.weekdayHabit.timeString)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.primary)
                .padding(.horizontal, .entryTimeHorizontalPadding)
                .padding(.vertical, .entryTimeVerticalPadding)
                .background(.thinMaterial, in: Capsule())
            
            Divider()
                        
            Text(entry.weekdayHabit.habit.title)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .entryHorizontalPadding)
        .padding(.vertical, .entryVerticalPadding)
        .background(
            .white.opacity(.entryBackgroundOpacity),
            in: RoundedRectangle(cornerRadius: .entryCornerRadius)
        )
    }
}

private extension CGFloat {
    static let entryRowSpacing = 12.0
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
    static let entryHorizontalPadding = 10.0
    static let entryVerticalPadding = 8.0
    static let entryCornerRadius = 12.0
}

private extension Double {
    static let entryBackgroundOpacity = 0.15
}
