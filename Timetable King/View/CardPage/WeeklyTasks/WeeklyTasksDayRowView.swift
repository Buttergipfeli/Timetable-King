import SwiftUI

struct WeeklyTasksDayRowView: View {
    let digest: WeekdayDigest

    var body: some View {
        HStack(spacing: .rowSpacing) {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                Text(digest.weekday.label)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("timetable.weekday.tasks.count".localized(digest.habits.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: .spacerMinLength)

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
