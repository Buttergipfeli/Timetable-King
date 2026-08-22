import WidgetKit

struct TimetableWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: TimetableWidgetSnapshot
    let palette: AppPalette
}
