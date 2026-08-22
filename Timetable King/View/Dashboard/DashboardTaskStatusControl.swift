import SwiftUI

struct DashboardTaskStatusControl: View {
    let entry: TodayTaskEntry
    let onSelectStatus: (HabitState) -> Bool

    var body: some View {
        Menu {
            statusButton(status: .done, label: "timetable.today.task.status.done")
            statusButton(status: .failed, label: "timetable.today.task.status.failed")
            statusButton(status: .none, label: "timetable.today.task.status.none")
        } label: {
            statusIcon
                .frame(width: .controlSize, height: .controlSize)
        }
        .disabled(entry.displayStatus == .future)
        .accessibilityLabel(entry.statusTitle)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch entry.displayStatus {
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        case .todo:
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
        case .future:
            Image(systemName: "clock.badge")
                .foregroundStyle(.blue)
        }
    }

    private func statusButton(status: HabitState, label: LocalizedStringKey) -> some View {
        Button {
            _ = onSelectStatus(status)
        } label: {
            Label(label, systemImage: systemImage(for: status))
        }
    }

    private func systemImage(for status: HabitState) -> String {
        switch status {
        case .done: "checkmark.circle"
        case .failed: "xmark.circle"
        case .none: "circle"
        }
    }
}

private extension CGFloat {
    static let controlSize = 28.0
}
