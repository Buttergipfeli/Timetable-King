import SwiftUI
import WidgetKit

struct TimetableKingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: TimetableWidgetConstants.kind,
            provider: TimetableWidgetProvider()
        ) { entry in
            TimetableWidgetView(entry: entry)
        }
        .configurationDisplayName("Timetable King")
        .description("See your next tasks and weekly progress at a glance.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ]

        if #available(iOSApplicationExtension 27.0, *) {
            families.append(.systemExtraLargePortrait)
        }

        return families
    }
}
