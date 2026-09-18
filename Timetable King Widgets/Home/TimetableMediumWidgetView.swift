import SwiftUI

struct TimetableMediumWidgetView: View {
    let snapshot: TimetableWidgetSnapshot

    private var tasks: [TimetableWidgetTask] {
        Array(snapshot.upcomingTasks.prefix(3))
    }

    private var taskCountLabel: String {
        snapshot.upcomingTasks.count > tasks.count
            ? "\(tasks.count) of \(snapshot.upcomingTasks.count)"
            : "\(snapshot.upcomingTasks.count) left"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily plan")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tint)
                        .textCase(.uppercase)
                    Text("Your next tasks")
                        .font(.headline)
                }
                Spacer(minLength: 8)
                Text(taskCountLabel)
                    .font(.caption.bold())
                    .foregroundStyle(.tint)
            }

            if tasks.isEmpty {
                Spacer(minLength: 4)
                Label(
                    resolvedStateTitle,
                    systemImage: resolvedStateIcon
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                Spacer(minLength: 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        Link(destination: TimetableDeepLink.taskURL(taskID: task.id)) {
                            TimetableWidgetTaskRow(task: task)
                        }
                        .buttonStyle(.plain)
                        .frame(maxHeight: .infinity)

                        if index < tasks.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var resolvedStateIcon: String {
        if !snapshot.hasTasksToday {
            return "calendar.badge.checkmark"
        }
        return snapshot.isTodayComplete ? "checkmark.circle.fill" : "checkmark.circle"
    }

    private var resolvedStateTitle: String {
        if !snapshot.hasTasksToday {
            return "No tasks today"
        }
        return snapshot.isTodayComplete ? "All tasks completed" : "No open tasks"
    }
}

private struct TimetableWidgetTaskRow: View {
    let task: TimetableWidgetTask

    var body: some View {
        HStack(spacing: 8) {
            Text(task.timeText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)
                .monospacedDigit()
                .frame(width: 42, alignment: .leading)
            Text(task.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption2.bold())
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .privacySensitive()
    }
}
