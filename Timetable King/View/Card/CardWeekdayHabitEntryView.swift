import SwiftUI

struct CardWeekdayHabitEntryView: View {
    let entry: TodayTaskEntry
    var allowsStatusEditing: Bool = false
    let onOpen: () -> Void
    var onSelectStatus: ((TodayTaskEntry, HabitState) -> Bool)? = nil
    
    var body: some View {
        CardEntryView {
            Button(action: onOpen) {
                HStack(spacing: .entryContentSpacing) {
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            TodayTaskStatusBadge(
                entry: entry,
                allowsEditing: allowsStatusEditing,
                onSelectStatus: { status in
                    onSelectStatus?(entry, status) ?? false
                }
            )
        }
    }
}

private extension CGFloat {
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
    static let entryContentSpacing = 12.0
}
