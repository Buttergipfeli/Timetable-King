import SwiftUI

struct TodayTaskDetailView: View {
    @State private var viewModel = TodayTaskDetailViewModel()

    var showCloseButton: Bool
    var allowsStatusEditing: Bool = false
    let entry: TodayTaskEntry
    let onUpdateStatus: ((TodayTaskEntry, HabitState) -> Bool)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                detailCard(title: "timetable.today.task.detail.time", value: entry.timeString)
                detailCard(title: "timetable.today.task.detail.title", value: entry.title)
                statusCard
                detailCard(
                    title: "timetable.today.task.detail.description.title",
                    value: currentDetailDescription
                )
            }
            .padding(.horizontal, .screenPadding)
            .padding(.vertical, .screenVerticalPadding)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showCloseButton {
                DismissToolbarItem()
            }
        }
        .onChange(of: entry, initial: true) {
            viewModel.map(entry: entry)
        }
    }

    private func detailCard(title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: .cardContentSpacing) {
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

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: .cardContentSpacing) {
            Text("timetable.today.task.detail.status")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)

            if allowsStatusEditing, entry.displayStatus != .future, let onUpdateStatus {
                Menu {
                    Button {
                        if onUpdateStatus(entry, .done) {
                            viewModel.setStatus(.done)
                        }
                    } label: {
                        statusOptionLabel(
                            title: "timetable.today.task.status.done".localized,
                            status: .done
                        )
                    }

                    Button {
                        if onUpdateStatus(entry, .failed) {
                            viewModel.setStatus(.failed)
                        }
                    } label: {
                        statusOptionLabel(
                            title: "timetable.today.task.status.failed".localized,
                            status: .failed
                        )
                    }

                    Button {
                        if onUpdateStatus(entry, .none) {
                            viewModel.setStatus(.none)
                        }
                    } label: {
                        statusOptionLabel(
                            title: "timetable.today.task.status.none".localized,
                            status: .todo
                        )
                    }
                } label: {
                    HStack(spacing: .statusMenuSpacing) {
                        Text(viewModel.currentStatus.title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)

                        Spacer()

                        statusBadge(status: viewModel.currentStatus)

                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                Text(entry.statusTitle)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .cardCornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var currentDetailDescription: String {
        if allowsStatusEditing {
            return viewModel.currentStatus.detailDescription(timeString: entry.timeString)
        }

        return entry.detailDescription
    }

    private func statusOptionLabel(title: String, status: TodayTaskDisplayStatus) -> some View {
        HStack(spacing: .statusMenuSpacing) {
            Text(title)

            Spacer()

            statusBadge(status: status)
        }
    }

    private func statusBadge(status: TodayTaskDisplayStatus) -> some View {
        Text(status.title)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, .statusBadgeHorizontalPadding)
            .padding(.vertical, .statusBadgeVerticalPadding)
            .background(status.color, in: Capsule())
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let contentSpacing = 16.0
    static let cardPadding = 16.0
    static let cardCornerRadius = 18.0
    static let cardContentSpacing = 8.0
    static let statusMenuSpacing = 10.0
    static let statusBadgeHorizontalPadding = 12.0
    static let statusBadgeVerticalPadding = 8.0
}
