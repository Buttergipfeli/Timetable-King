import SwiftUI

struct DashboardWeeklySummaryView: View {
    @Environment(\.appTheme) private var theme

    let snapshot: DashboardSnapshot
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            DashboardSurface {
                VStack(alignment: .leading, spacing: .contentSpacing) {
                    Text("dashboard.week.kicker")
                        .font(.caption2.weight(.bold))
                        .tracking(.kickerTracking)
                        .foregroundStyle(theme.accent)

                    header
                    weekdayValues
                }
                .padding(.cardPadding)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.weeklySummary.button")
        .accessibilityHint("dashboard.open.details")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: .headerSpacing) {
            VStack(alignment: .leading, spacing: .titleSpacing) {
                Text("timetable.card.weekly.summary")
                    .font(.headline.weight(.bold))
                    .multilineTextAlignment(.leading)

                Text(progressDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: .minimumSpacer)

            Text(percentageDescription)
                .font(.subheadline.monospacedDigit().weight(.bold))
                .foregroundStyle(theme.accent)
                .padding(.horizontal, .percentageHorizontalPadding)
                .padding(.vertical, .percentageVerticalPadding)
                .background(theme.accentSurface, in: Capsule())
        }
    }

    private var weekdayValues: some View {
        HStack(spacing: .weekdaySpacing) {
            ForEach(Weekday.allCases, id: \.self) { weekday in
                let progress = snapshot.progress(for: weekday)

                VStack(spacing: .labelSpacing) {
                    Text(progress.displayValue)
                        .font(.caption2.monospacedDigit().weight(.bold))
                        .foregroundStyle(valueColor(for: progress))
                        .frame(maxWidth: .infinity, minHeight: .valueHeight)
                        .background(valueBackground(for: progress), in: Circle())
                        .overlay {
                            Circle()
                                .stroke(
                                    weekday.isToday ? theme.accent : .primary.opacity(.borderOpacity),
                                    lineWidth: weekday.isToday ? .todayBorderWidth : 1
                                )
                        }

                    Text(weekday.shortLabel)
                        .font(.system(size: .weekdayFontSize, weight: weekday.isToday ? .bold : .medium))
                        .foregroundStyle(weekday.isToday ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(weekday.label)
                .accessibilityValue(accessibilityValue(for: progress))
            }
        }
    }

    private var progressDescription: String {
        guard snapshot.weeklyTotalCount > 0 else {
            return "dashboard.week.empty".localized
        }

        return "dashboard.week.progress".localized(
            snapshot.weeklyCompletedCount,
            snapshot.weeklyTotalCount
        )
    }

    private var percentageDescription: String {
        guard snapshot.weeklyTotalCount > 0 else { return "–" }
        return snapshot.weeklyCompletionPercentage.formatted(
            .percent.precision(.fractionLength(0))
        )
    }

    private func valueColor(for progress: DashboardWeekdayProgress) -> Color {
        if progress.isComplete { return theme.accent }
        return progress.totalCount > 0 ? .primary : .secondary
    }

    private func valueBackground(for progress: DashboardWeekdayProgress) -> Color {
        progress.totalCount > 0 ? theme.accentSurface : .primary.opacity(.emptyBackgroundOpacity)
    }

    private func accessibilityValue(for progress: DashboardWeekdayProgress) -> String {
        guard progress.totalCount > 0 else { return "dashboard.week.day.empty".localized }
        return "dashboard.week.day.progress".localized(progress.completedCount, progress.totalCount)
    }
}

private extension CGFloat {
    static let cardPadding = 18.0
    static let contentSpacing = 13.0
    static let kickerTracking = 1.1
    static let headerSpacing = 10.0
    static let titleSpacing = 3.0
    static let minimumSpacer = 8.0
    static let percentageHorizontalPadding = 9.0
    static let percentageVerticalPadding = 5.0
    static let weekdaySpacing = 5.0
    static let labelSpacing = 5.0
    static let valueHeight = 36.0
    static let weekdayFontSize = 9.0
    static let todayBorderWidth = 2.0
}

private extension Double {
    static let borderOpacity = 0.08
    static let emptyBackgroundOpacity = 0.05
}
