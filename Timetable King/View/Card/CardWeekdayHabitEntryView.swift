import SwiftUI

struct CardWeekdayHabitEntryView: View {
    let entry: TodayTaskEntry
    var allowsStatusEditing: Bool = false
    var onSelectStatus: ((TodayTaskEntry, HabitState) -> Void)? = nil
    
    var body: some View {
        CardEntryView {
            Text(entry.timeString)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.primary)
                .padding(.horizontal, .entryTimeHorizontalPadding)
                .padding(.vertical, .entryTimeVerticalPadding)
                .background(.thinMaterial, in: Capsule())
            
            Divider()
                        
            Text(entry.title)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer()

            TodayTaskStatusBadge(
                entry: entry,
                allowsEditing: allowsStatusEditing,
                onSelectStatus: { status in
                    onSelectStatus?(entry, status)
                }
            )
        }
    }
}

private extension CGFloat {
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
}
