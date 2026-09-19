import WidgetKit

@MainActor
protocol WidgetSnapshotSyncing {
    func sync(
        _ dashboardSnapshot: DashboardSnapshot,
        recurringDigests: [WeekdayDigest],
        referenceDate: Date
    )
}

@MainActor
final class WidgetSnapshotService: WidgetSnapshotSyncing {
    private let store: TimetableWidgetSnapshotStore

    init() {
        store = TimetableWidgetSnapshotStore()
    }

    init(store: TimetableWidgetSnapshotStore) {
        self.store = store
    }

    func sync(
        _ dashboardSnapshot: DashboardSnapshot,
        recurringDigests: [WeekdayDigest],
        referenceDate: Date = .now
    ) {
        let calendar = Calendar.current
        let snapshot = TimetableWidgetSnapshot(
            generatedAt: referenceDate,
            weekStart: TimetableWidgetSnapshot.weekStart(for: referenceDate, calendar: calendar),
            week: mapCurrentWeek(dashboardSnapshot.weekdayDigests),
            recurringWeek: mapRecurringWeek(recurringDigests)
        )

        store.save(snapshot)
        WidgetCenter.shared.reloadTimelines(ofKind: TimetableWidgetConstants.kind)
    }

    private func mapCurrentWeek(_ digests: [WeekdayDigest]) -> [TimetableWidgetDay] {
        Weekday.allCases.map { weekday in
            let digest = digests.first { $0.weekday == weekday }
            let tasks = digest?.habits.map { habit in
                mapTask(
                    TodayTaskEntry(
                        habit: habit,
                        result: digest?.results.first { $0.weekdayHabit == habit }
                    )
                )
            } ?? []
            return mapDay(weekday, tasks: tasks)
        }
    }

    private func mapRecurringWeek(_ digests: [WeekdayDigest]) -> [TimetableWidgetDay] {
        Weekday.allCases.map { weekday in
            let tasks = digests
                .first { $0.weekday == weekday }?
                .habits
                .map { habit in
                    TimetableWidgetTask(
                        id: TimetableWidgetTask.identifier(
                            weekday: habit.weekday.rawValue,
                            hour: habit.hour,
                            minute: habit.minute,
                            title: habit.habit.title
                        ),
                        title: habit.habit.title,
                        hour: habit.hour,
                        minute: habit.minute,
                        status: .todo
                    )
                } ?? []
            return mapDay(weekday, tasks: tasks)
        }
    }

    private func mapDay(_ weekday: Weekday, tasks: [TimetableWidgetTask]) -> TimetableWidgetDay {
        TimetableWidgetDay(
            id: weekday.rawValue,
            weekdayIndex: weekday.sortIndex,
            label: weekday.shortLabel,
            tasks: tasks
        )
    }

    private func mapTask(_ entry: TodayTaskEntry) -> TimetableWidgetTask {
        TimetableWidgetTask(
            id: entry.widgetIdentifier,
            title: entry.title,
            hour: entry.habit.hour,
            minute: entry.habit.minute,
            status: mapStatus(entry.displayStatus)
        )
    }

    private func mapStatus(_ status: TodayTaskDisplayStatus) -> TimetableWidgetTaskStatus {
        switch status {
        case .done:
            .done
        case .failed:
            .failed
        case .todo, .future:
            .todo
        }
    }
}
