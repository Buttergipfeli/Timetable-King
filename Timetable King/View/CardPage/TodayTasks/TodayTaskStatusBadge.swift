import SwiftUI

struct TodayTaskStatusBadge: View {
    let entry: TodayTaskEntry
    var allowsEditing: Bool = false
    var onSelectStatus: ((HabitState) -> Bool)? = nil

    var body: some View {
        if allowsEditing, entry.displayStatus != .future, let onSelectStatus {
            Menu {
                Button {
                    _ = onSelectStatus(.done)
                } label: {
                    menuOption(
                        title: "timetable.today.task.status.done".localized,
                        color: TodayTaskDisplayStatus.done.color
                    )
                }

                Button {
                    _ = onSelectStatus(.failed)
                } label: {
                    menuOption(
                        title: "timetable.today.task.status.failed".localized,
                        color: TodayTaskDisplayStatus.failed.color
                    )
                }

                Button {
                    _ = onSelectStatus(.none)
                } label: {
                    menuOption(
                        title: "timetable.today.task.status.none".localized,
                        color: TodayTaskDisplayStatus.todo.color
                    )
                }
            } label: {
                badgeLabel
            }
        } else {
            badgeLabel
        }
    }

    private var badgeLabel: some View {
        Text(entry.statusTitle)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, .badgeHorizontalPadding)
            .padding(.vertical, .badgeVerticalPadding)
            .background(entry.displayStatus.color, in: Capsule())
    }

    private func menuOption(title: String, color: Color) -> some View {
        HStack(spacing: .menuContentSpacing) {
            Text(title)

            Spacer()

            Circle()
                .fill(color)
                .frame(width: .menuIndicatorSize, height: .menuIndicatorSize)
        }
    }
}

extension TodayTaskDisplayStatus {
    var color: Color {
        switch self {
        case .done:
            .green
        case .failed:
            .red
        case .todo:
            .gray
        case .future:
            .blue
        }
    }
}

private extension CGFloat {
    static let badgeHorizontalPadding = 12.0
    static let badgeVerticalPadding = 8.0
    static let menuIndicatorSize = 10.0
    static let menuContentSpacing = 10.0
}
