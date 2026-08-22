import SwiftUI

struct DashboardTodayTaskRow: View {
    @Environment(\.appTheme) private var theme

    let entry: TodayTaskEntry
    let onOpen: () -> Void
    let onSelectStatus: (HabitState) -> Bool

    var body: some View {
        HStack(spacing: .rowSpacing) {
            DashboardTaskStatusControl(entry: entry, onSelectStatus: onSelectStatus)

            Button(action: onOpen) {
                HStack(spacing: .contentSpacing) {
                    Text(entry.timeString)
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(theme.accent)
                        .frame(width: .timeWidth, alignment: .leading)

                    VStack(alignment: .leading, spacing: .titleSpacing) {
                        Text(entry.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(entry.statusTitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, .verticalPadding)
    }
}

private extension CGFloat {
    static let rowSpacing = 10.0
    static let contentSpacing = 10.0
    static let titleSpacing = 2.0
    static let verticalPadding = 6.0
    static let timeWidth = 42.0
}
