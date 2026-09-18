import SwiftUI
import WidgetKit

struct TimetableAccessoryCircularView: View {
    let snapshot: TimetableWidgetSnapshot

    var body: some View {
        if snapshot.totalTodayCount > 0 {
            Gauge(value: snapshot.dailyProgress) {
                Text("Done")
            } currentValueLabel: {
                Text("\(snapshot.completedTodayCount)/\(snapshot.totalTodayCount)")
                    .font(.caption2.bold())
                    .monospacedDigit()
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .widgetAccentable()
            .accessibilityLabel("Daily progress")
            .accessibilityValue("\(snapshot.completedTodayCount) of \(snapshot.totalTodayCount) completed")
        } else {
            Image(systemName: snapshot.hasTasksToday ? "forward.end.circle" : "calendar.badge.checkmark")
                .font(.title2)
                .widgetAccentable()
                .accessibilityLabel(snapshot.hasTasksToday ? "No open tasks" : "No tasks today")
        }
    }
}
