import SwiftUI

struct TodayTaskRowView: View {
    let entry: TodayTaskEntry

    var body: some View {
        HStack(spacing: .rowSpacing) {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                Text(entry.timeString)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(.titleLineLimit)
            }

            Spacer(minLength: .spacerMinLength)

            TodayTaskStatusBadge(entry: entry)
        }
        .padding(.horizontal, .rowHorizontalPadding)
        .padding(.vertical, .rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .rowCornerRadius)
                .fill(Color(.systemBackground))
        )
    }
}

private extension CGFloat {
    static let rowSpacing = 12.0
    static let rowHorizontalPadding = 14.0
    static let rowVerticalPadding = 12.0
    static let rowCornerRadius = 16.0
    static let spacerMinLength = 12.0
    static let contentSpacing = 4.0
}

private extension Int {
    static let titleLineLimit = 2
}
