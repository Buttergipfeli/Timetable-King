import SwiftUI
import UserNotifications

struct TaskReminderSection: View {
    @Environment(\.openURL) private var openURL
    @State private var service = TaskReminderService.shared
    @Binding var reminder: TaskReminder

    var body: some View {
        Section {
            Picker("task.reminder.title", selection: $reminder) {
                ForEach(TaskReminder.allCases, id: \.self) { option in
                    Text(option.title).tag(option)
                }
            }
            .accessibilityIdentifier("task.reminder.picker")

            if reminder != .off, service.authorizationStatus == .denied {
                Text("task.reminder.denied")
                    .foregroundStyle(.secondary)
                Button("task.reminder.open.settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }
            if reminder != .off, service.hasSchedulingError {
                Text("task.reminder.error")
                    .foregroundStyle(.red)
            }
        } header: {
            Text("task.reminder.title")
        } footer: {
            if reminder != .off {
                Text("task.reminder.scheduling.description")
            }
        }
        .task { await service.refreshAuthorization() }
        .onChange(of: reminder) {
            guard reminder != .off else { return }
            Task { await service.requestAuthorization() }
        }
    }
}
