import SwiftUI

struct TimetableAccessoryInlineView: View {
    let snapshot: TimetableWidgetSnapshot

    var body: some View {
        if let task = snapshot.nextTask {
            Link(destination: TimetableDeepLink.taskURL(taskID: task.id)) {
                Label("\(task.timeText) · \(task.title)", systemImage: "clock")
            }
            .privacySensitive()
        } else if snapshot.totalTodayCount > 0 {
            Link(destination: TimetableDeepLink.todayTasksURL) {
                Label("\(snapshot.completedTodayCount)/\(snapshot.totalTodayCount) completed", systemImage: "checkmark.circle")
            }
        } else {
            Link(destination: TimetableDeepLink.todayTasksURL) {
                Label("No tasks today", systemImage: "calendar.badge.checkmark")
            }
        }
    }
}
