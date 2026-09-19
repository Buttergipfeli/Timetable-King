import Foundation
import Observation
import UserNotifications

@MainActor
protocol TaskReminderSyncing {
    func sync(schedules: [WeekdayHabit])
}

@MainActor
@Observable
final class TaskReminderService: NSObject, TaskReminderSyncing, UNUserNotificationCenterDelegate {
    static let shared = TaskReminderService()

    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private(set) var hasSchedulingError = false
    var openedTaskURL: URL?

    @ObservationIgnored private let center = UNUserNotificationCenter.current()
    @ObservationIgnored private var pendingSync: Task<Void, Never>?
    @ObservationIgnored private var latestPlan: [PlannedTaskReminder] = []
    @ObservationIgnored private var latestDeliveryState = TaskReminderDeliveryState(schedules: [])

    override init() {
        super.init()
        center.delegate = self
    }

    func refreshAuthorization() async {
        authorizationStatus = await center.notificationSettings().authorizationStatus
    }

    func requestAuthorization() async {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound])
            await refreshAuthorization()
            enqueue(latestPlan)
        } catch {
            hasSchedulingError = true
        }
    }

    func sync(schedules: [WeekdayHabit]) {
        latestPlan = TaskReminderPlanner().plan(schedules: schedules)
        latestDeliveryState = TaskReminderDeliveryState(schedules: schedules)
        enqueue(latestPlan)
    }

    private func enqueue(_ plan: [PlannedTaskReminder]) {
        let deliveryState = latestDeliveryState
        let previousSync = pendingSync
        previousSync?.cancel()
        pendingSync = Task {
            await previousSync?.value
            guard !Task.isCancelled else { return }
            await replacePendingReminders(with: plan, deliveryState: deliveryState)
        }
    }

    private func replacePendingReminders(
        with plan: [PlannedTaskReminder],
        deliveryState: TaskReminderDeliveryState
    ) async {
        await refreshAuthorization()
        let pending = await center.pendingNotificationRequests()
        guard !Task.isCancelled else { return }

        let canNotify = authorizationStatus == .authorized || authorizationStatus == .provisional
        let otherCount = pending.filter { !$0.identifier.hasPrefix(TaskReminderPlanner.identifierPrefix) }.count
        let desired = canNotify ? Array(plan.prefix(max(0, TaskReminderPlanner.pendingLimit - otherCount))) : []
        let desiredIDs = Set(desired.map(\.id))
        let obsoleteIDs = pending.filter {
            $0.identifier.hasPrefix(TaskReminderPlanner.identifierPrefix) && !desiredIDs.contains($0.identifier)
        }.map(\.identifier)
        center.removePendingNotificationRequests(withIdentifiers: obsoleteIDs)

        let delivered = await center.deliveredNotifications()
        guard !Task.isCancelled else { return }
        center.removeDeliveredNotifications(withIdentifiers: delivered.filter {
            $0.request.identifier.hasPrefix(TaskReminderPlanner.identifierPrefix)
                && !deliveryState.contains(userInfo: $0.request.content.userInfo)
        }.map { $0.request.identifier })

        do {
            for reminder in desired {
                guard !Task.isCancelled else { return }
                guard reminder.fireDate > .now else { continue }
                let content = UNMutableNotificationContent()
                content.title = reminder.title
                content.body = "task.reminder.notification.body".localized(
                    reminder.taskDate.formatted(date: .omitted, time: .shortened)
                )
                content.sound = .default
                content.userInfo = reminder.notificationUserInfo
                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second], from: reminder.fireDate
                )
                try await center.add(UNNotificationRequest(
                    identifier: reminder.id,
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                ))
            }
            hasSchedulingError = false
        } catch {
            hasSchedulingError = true
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let value = response.notification.request.content.userInfo["taskURL"] as? String,
              let url = URL(string: value) else { return }
        await MainActor.run {
            guard let destination = TimetableDeepLink.destination(for: url) else { return }
            if case .reminder = destination {
                openedTaskURL = url
            } else {
                openedTaskURL = TimetableDeepLink.todayTasksURL
            }
        }
    }
}
