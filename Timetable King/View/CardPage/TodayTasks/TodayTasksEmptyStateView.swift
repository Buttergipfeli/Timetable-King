import SwiftUI

struct TodayTasksEmptyStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(TodayTasksEmptyStateViewLayout.emptyStatePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: TodayTasksEmptyStateViewLayout.rowCornerRadius)
                .fill(Color(.systemBackground))
        )
    }
}

private enum TodayTasksEmptyStateViewLayout {
    static let emptyStatePadding = 16.0
    static let rowCornerRadius = 16.0
}
