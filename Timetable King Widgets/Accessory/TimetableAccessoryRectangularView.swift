import SwiftUI
import WidgetKit

struct TimetableAccessoryRectangularView: View {
    let snapshot: TimetableWidgetSnapshot

    var body: some View {
        if snapshot.totalTodayCount > 0 {
            progressContent
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Label("No tasks today", systemImage: "calendar.badge.checkmark")
                    .font(.headline)
                Text("Your schedule is clear")
                    .font(.caption)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var progressContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline) {
                Text("Daily progress")
                    .font(.headline)
                Spacer(minLength: 8)
                Text("\(snapshot.completedTodayCount)/\(snapshot.totalTodayCount)")
                    .font(.caption.bold())
                    .monospacedDigit()
            }

            ProgressView(value: snapshot.dailyProgress)
                .widgetAccentable()

            if let task = snapshot.nextTask {
                Link(destination: TimetableDeepLink.taskURL(taskID: task.id)) {
                    HStack(spacing: 5) {
                        Text(task.timeText)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                        Text(task.title)
                            .lineLimit(1)
                    }
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .privacySensitive()
                }
                .buttonStyle(.plain)
            } else {
                Text(snapshot.isTodayComplete ? "All tasks completed" : "No open tasks")
                    .font(.caption)
                    .lineLimit(1)
            }
        }
    }
}
