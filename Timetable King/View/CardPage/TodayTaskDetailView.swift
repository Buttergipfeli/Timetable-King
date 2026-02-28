import SwiftUI

struct TodayTaskDetailView: View {
    let entry: TodayTasksViewModel.Entry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                detailCard(title: "Time", value: entry.timeString)
                detailCard(title: "Title", value: entry.title)
                detailCard(title: "Status", value: entry.statusTitle)
                detailCard(title: "Description", value: entry.detailDescription)
            }
            .padding(.horizontal, .screenPadding)
            .padding(.vertical, .screenVerticalPadding)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard(title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding(.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .cardCornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let contentSpacing = 16.0
    static let cardPadding = 16.0
    static let cardCornerRadius = 18.0
}
