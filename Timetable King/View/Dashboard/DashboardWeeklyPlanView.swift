import SwiftUI

struct DashboardWeeklyPlanView: View {
    @Environment(\.appTheme) private var theme

    let snapshot: DashboardSnapshot
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            DashboardSurface {
                VStack(alignment: .leading, spacing: .contentSpacing) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: .titleSpacing) {
                            Text("dashboard.plan.kicker")
                                .font(.caption2.weight(.bold))
                                .tracking(.kickerTracking)
                                .foregroundStyle(theme.accent)

                            Text("timetable.card.my.weekly.tasks")
                                .font(.headline.weight(.bold))
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        Image(systemName: "calendar")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(theme.accent)
                            .frame(width: .iconSize, height: .iconSize)
                            .background(theme.accentSurface, in: Circle())
                    }

                    HStack(alignment: .lastTextBaseline) {
                        HStack(alignment: .lastTextBaseline, spacing: .metricSpacing) {
                            Text(snapshot.weeklyTaskCount, format: .number)
                                .font(.title2.monospacedDigit().weight(.bold))

                            Text("dashboard.plan.tasks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(snapshot.activeWeekdayCount)/\(Weekday.allCases.count)")
                            .font(.caption.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    weekdayDots
                }
                .padding(.cardPadding)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("dashboard.open.details")
    }

    private var weekdayDots: some View {
        HStack(spacing: .dotSpacing) {
            ForEach(Weekday.allCases, id: \.self) { weekday in
                VStack(spacing: .dotLabelSpacing) {
                    Circle()
                        .fill(snapshot.hasWeeklyTasks(on: weekday) ? theme.accent : .primary.opacity(.inactiveDotOpacity))
                        .frame(width: .dotSize, height: .dotSize)

                    Text(weekday.shortLabel)
                        .font(.system(size: .weekdayFontSize, weight: weekday.isToday ? .bold : .medium))
                        .foregroundStyle(weekday.isToday ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private extension CGFloat {
    static let cardPadding = 18.0
    static let contentSpacing = 12.0
    static let titleSpacing = 3.0
    static let kickerTracking = 1.1
    static let iconSize = 36.0
    static let metricSpacing = 5.0
    static let dotSpacing = 7.0
    static let dotLabelSpacing = 5.0
    static let dotSize = 8.0
    static let weekdayFontSize = 9.0
}

private extension Double {
    static let inactiveDotOpacity = 0.1
}
