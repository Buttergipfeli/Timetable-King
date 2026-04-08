import SwiftUI

struct WeeklySummaryRowView: View {
    let entry: WeeklySummaryEntry

    var body: some View {
        HStack(spacing: .rowSpacing) {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                Text(entry.digest.weekday.label)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(entry.completedCount) / \(entry.totalCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if entry.futureCount > 0 {
                    Text("timetable.weekly.summary.future.count".localized(entry.futureCount))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer(minLength: .spacerMinLength)

            Text(entry.digest.performanceEmoji)
                .font(.title2)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
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
    static let rowVerticalPadding = 14.0
    static let rowCornerRadius = 16.0
    static let spacerMinLength = 12.0
    static let contentSpacing = 4.0
}
