import WidgetKit

struct TimetableWidgetProvider: TimelineProvider {
    private let snapshotStore = TimetableWidgetSnapshotStore()
    private let paletteStorage = AppPaletteStorage()

    func placeholder(in context: Context) -> TimetableWidgetEntry {
        TimetableWidgetEntry(
            date: .now,
            snapshot: .placeholder(),
            palette: .fallback
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TimetableWidgetEntry) -> Void) {
        completion(entry(at: .now, usePlaceholder: context.isPreview))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimetableWidgetEntry>) -> Void) {
        let now = Date.now
        let calendar = Calendar.current
        let snapshot = snapshotStore.load() ?? .empty(referenceDate: now, calendar: calendar)
        let updateDates = (1...7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: now))
        }
        let entries = ([now] + updateDates).map { date in
            entry(at: date, snapshot: snapshot.resolved(for: date, calendar: calendar))
        }
        let nextUpdate = updateDates.last ?? now.addingTimeInterval(604_800)
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }

    private func entry(at date: Date, usePlaceholder: Bool = false) -> TimetableWidgetEntry {
        let snapshot = usePlaceholder
            ? TimetableWidgetSnapshot.placeholder(referenceDate: date)
            : (snapshotStore.load() ?? .empty(referenceDate: date))
        return entry(at: date, snapshot: snapshot.resolved(for: date))
    }

    private func entry(at date: Date, snapshot: TimetableWidgetSnapshot) -> TimetableWidgetEntry {
        TimetableWidgetEntry(date: date, snapshot: snapshot, palette: paletteStorage.load() ?? .fallback)
    }
}
