import SwiftUI

struct TodayTaskRowView: View {
    let entry: TodayTaskEntry

    var body: some View {
        HStack(spacing: TodayTaskRowViewLayout.rowSpacing) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.timeString)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            TodayTaskStatusBadge(entry: entry)
        }
        .padding(.horizontal, TodayTaskRowViewLayout.rowHorizontalPadding)
        .padding(.vertical, TodayTaskRowViewLayout.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: TodayTaskRowViewLayout.rowCornerRadius)
                .fill(Color(.systemBackground))
        )
    }
}

private enum TodayTaskRowViewLayout {
    static let rowSpacing = 12.0
    static let rowHorizontalPadding = 14.0
    static let rowVerticalPadding = 12.0
    static let rowCornerRadius = 16.0
}
