import SwiftUI

struct DashboardTodayTasksView: View {
    @Environment(\.appTheme) private var theme

    let entries: [TodayTaskEntry]
    let onOpenEntry: (TodayTaskEntry) -> Void
    let onSelectStatus: (TodayTaskEntry, HabitState) -> Bool
    let onShowAll: () -> Void
    let onAddTask: () -> Void

    var body: some View {
        DashboardSurface {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                header

                if entries.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .padding(.cardPadding)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: .titleSpacing) {
                Text("dashboard.today.tasks.kicker")
                    .font(.caption2.weight(.bold))
                    .tracking(.kickerTracking)
                    .foregroundStyle(theme.accent)

                Text("timetable.today.tasks.title")
                    .font(.headline.weight(.bold))
            }

            Spacer()

            Button("dashboard.show.all", action: onShowAll)
                .font(.caption.weight(.semibold))
        }
    }

    private var taskList: some View {
        VStack(spacing: 0) {
            ForEach(Array(entries.prefix(.previewTaskCount).enumerated()), id: \.element.id) { index, entry in
                if index > 0 {
                    Divider()
                        .padding(.leading, .dividerLeadingPadding)
                }

                DashboardTodayTaskRow(
                    entry: entry,
                    onOpen: { onOpenEntry(entry) },
                    onSelectStatus: { onSelectStatus(entry, $0) }
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: .emptySpacing) {
            Image(systemName: "checklist")
                .font(.title2)
                .foregroundStyle(theme.accent)

            Text("dashboard.today.empty.title")
                .font(.subheadline.weight(.semibold))

            Text("dashboard.today.empty.message")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("dashboard.add.task", action: onAddTask)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .emptyVerticalPadding)
    }
}

private extension Int {
    static let previewTaskCount = 3
}

private extension CGFloat {
    static let cardPadding = 18.0
    static let contentSpacing = 12.0
    static let titleSpacing = 3.0
    static let kickerTracking = 1.1
    static let dividerLeadingPadding = 38.0
    static let emptySpacing = 8.0
    static let emptyVerticalPadding = 18.0
}
