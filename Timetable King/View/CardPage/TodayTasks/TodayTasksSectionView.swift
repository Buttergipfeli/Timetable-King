import SwiftUI

struct TodayTasksSectionView: View {
    let title: LocalizedStringKey
    let entries: [TodayTaskEntry]
    let emptyTitle: LocalizedStringKey
    let emptyMessage: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: .sectionInnerSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.title3.weight(.bold))

                Spacer()

                Text("timetable.today.tasks.status.title")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if entries.isEmpty {
                TodayTasksEmptyStateView(title: emptyTitle, message: emptyMessage)
            } else {
                VStack(spacing: .rowSpacing) {
                    ForEach(entries) { entry in
                        NavigationLink {
                            TodayTaskDetailView(entry: entry)
                        } label: {
                            TodayTaskRowView(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.sectionPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .sectionCornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private extension CGFloat {
    static let sectionInnerSpacing = 14.0
    static let sectionPadding = 16.0
    static let sectionCornerRadius = 20.0
    static let rowSpacing = 12.0
}
