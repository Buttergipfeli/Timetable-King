import SwiftUI

struct WeeklyTaskRowView: View {
    let habit: WeekdayHabit

    var body: some View {
        HStack(spacing: .rowSpacing) {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                Text(habit.timeString)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Text(habit.habit.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(.titleLineLimit)
                    .multilineTextAlignment(.leading)
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
    static let rowVerticalPadding = 12.0
    static let rowCornerRadius = 16.0
    static let spacerMinLength = 12.0
    static let contentSpacing = 4.0
}

private extension Int {
    static let titleLineLimit = 2
}
