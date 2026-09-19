import SwiftUI

struct TimetableSmallWidgetView: View {
    let snapshot: TimetableWidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Next task")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.tint)
                .textCase(.uppercase)

            if let task = snapshot.nextTask {
                Link(destination: TimetableDeepLink.taskURL(taskID: task.id)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)

                        if snapshot.upcomingTasks.count > 1 {
                            Text("+\(snapshot.upcomingTasks.count - 1) more today")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 4)

                        HStack(alignment: .lastTextBaseline) {
                            Text(task.timeText)
                                .font(.title2.bold())
                                .foregroundStyle(.primary)
                                .monospacedDigit()
                            Spacer(minLength: 4)
                            Image(systemName: "arrow.up.right")
                                .font(.caption.bold())
                                .foregroundStyle(.tint)
                                .accessibilityHidden(true)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .privacySensitive()
                }
                .buttonStyle(.plain)
            } else {
                Spacer(minLength: 4)
                Image(systemName: resolvedStateIcon)
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                Text(resolvedStateTitle)
                    .font(.headline)
                    .lineLimit(2)
            }
        }
    }

    private var resolvedStateIcon: String {
        if snapshot.totalTodayCount == 0 {
            return "calendar.badge.checkmark"
        }
        return snapshot.isTodayComplete ? "checkmark.circle.fill" : "checkmark.circle"
    }

    private var resolvedStateTitle: String {
        if snapshot.totalTodayCount == 0 {
            return "No tasks today"
        }
        return snapshot.isTodayComplete ? "All done" : "No open tasks"
    }
}
