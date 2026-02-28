import SwiftUI

struct TodayTasksView: View {
    @State private var viewModel = TodayTasksViewModel()

    @Environment(\.dismiss) private var dismiss

    let todayDigest: WeekdayDigest?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .sectionSpacing) {
                    TodayTasksSectionView(
                        title: "Finished",
                        entries: viewModel.finishedEntries,
                        emptyTitle: "No finished entries",
                        emptyMessage: "Tasks with a defined result appear here."
                    )

                    TodayTasksSectionView(
                        title: "Todo",
                        entries: viewModel.todoEntries,
                        emptyTitle: "No open entries",
                        emptyMessage: "Tasks without a defined result appear here."
                    )
                }
                .padding(.horizontal, .screenPadding)
                .padding(.vertical, .screenVerticalPadding)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today's tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.semibold))
                    }
                }
            }
        }
        .onChange(of: todayDigest, initial: true) {
            viewModel.map(todayDigest: todayDigest)
        }
    }
}

private struct TodayTasksSectionView: View {
    let title: LocalizedStringKey
    let entries: [TodayTasksViewModel.Entry]
    let emptyTitle: LocalizedStringKey
    let emptyMessage: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: .sectionInnerSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.title3.weight(.bold))

                Spacer()

                Text("Status")
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

private struct TodayTaskRowView: View {
    let entry: TodayTasksViewModel.Entry

    var body: some View {
        HStack(spacing: .rowSpacing) {
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
        .padding(.horizontal, .rowHorizontalPadding)
        .padding(.vertical, .rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .rowCornerRadius)
                .fill(Color(.systemBackground))
        )
    }
}

private struct TodayTaskStatusBadge: View {
    let entry: TodayTasksViewModel.Entry

    var body: some View {
        Text(entry.statusTitle)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, .badgeHorizontalPadding)
            .padding(.vertical, .badgeVerticalPadding)
            .frame(minWidth: .badgeMinWidth)
            .background(entry.statusColor, in: Capsule())
    }
}

private struct TodayTasksEmptyStateView: View {
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
        .padding(.emptyStatePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .rowCornerRadius)
                .fill(Color(.systemBackground))
        )
    }
}

private extension TodayTasksViewModel.Entry {
    var statusColor: Color {
        switch state {
        case .done:
            .green
        case .failed:
            .red
        case .undefined:
            .gray
        }
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let sectionSpacing = 20.0
    static let sectionInnerSpacing = 14.0
    static let sectionPadding = 16.0
    static let sectionCornerRadius = 20.0
    static let rowSpacing = 12.0
    static let rowHorizontalPadding = 14.0
    static let rowVerticalPadding = 12.0
    static let rowCornerRadius = 16.0
    static let badgeHorizontalPadding = 12.0
    static let badgeVerticalPadding = 8.0
    static let badgeMinWidth = 92.0
    static let emptyStatePadding = 16.0
}
