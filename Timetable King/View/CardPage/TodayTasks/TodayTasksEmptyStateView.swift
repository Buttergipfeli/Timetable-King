import SwiftUI

struct TodayTasksEmptyStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: .contentSpacing) {
            Text(title)
                .font(.headline.weight(.semibold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.emptyStatePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .rowCornerRadius)
                .fill(Color(.systemBackground))
        )
    }
}

private extension CGFloat {
    static let emptyStatePadding = 16.0
    static let rowCornerRadius = 16.0
    static let contentSpacing = 8.0
}
