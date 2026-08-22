import SwiftUI
import WidgetKit

struct TimetableWidgetView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetFamily) private var family

    let entry: TimetableWidgetEntry

    var body: some View {
        content
            .tint(accentColor)
            .widgetURL(defaultURL)
            .containerBackground(for: .widget) {
                containerBackground
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryInline:
            TimetableAccessoryInlineView(snapshot: entry.snapshot)
        case .accessoryCircular:
            TimetableAccessoryCircularView(snapshot: entry.snapshot)
        case .accessoryRectangular:
            TimetableAccessoryRectangularView(snapshot: entry.snapshot)
        case .systemSmall:
            TimetableSmallWidgetView(snapshot: entry.snapshot)
        case .systemMedium:
            TimetableMediumWidgetView(snapshot: entry.snapshot)
        case .systemLarge, .systemExtraLarge, .systemExtraLargePortrait:
            TimetableLargeWidgetView(snapshot: entry.snapshot)
        @unknown default:
            TimetableMediumWidgetView(snapshot: entry.snapshot)
        }
    }

    private var paletteVariant: AppPaletteVariant {
        colorScheme == .dark ? entry.palette.dark : entry.palette.light
    }

    private var accentColor: Color {
        paletteVariant.accent.widgetColor
    }

    private var defaultURL: URL {
        switch family {
        case .accessoryInline:
            entry.snapshot.nextTask.map { TimetableDeepLink.taskURL(taskID: $0.id) }
                ?? TimetableDeepLink.todayTasksURL
        case .systemLarge, .systemExtraLarge, .systemExtraLargePortrait:
            TimetableDeepLink.weeklySummaryURL
        default:
            TimetableDeepLink.todayTasksURL
        }
    }

    @ViewBuilder
    private var containerBackground: some View {
        switch family {
        case .accessoryInline, .accessoryCircular, .accessoryRectangular:
            Color.clear
        default:
            paletteVariant.surface.widgetColor
        }
    }
}

extension HSLColor {
    var widgetColor: Color {
        Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}
