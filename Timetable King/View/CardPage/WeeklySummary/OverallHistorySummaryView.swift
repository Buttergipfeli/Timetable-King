import SwiftUI

struct OverallHistorySummaryView: View {
    @Environment(\.appTheme) private var theme

    let score: CompletionScore

    var body: some View {
        VStack(alignment: .leading, spacing: .contentSpacing) {
            HStack(alignment: .center, spacing: .headerSpacing) {
                VStack(alignment: .leading, spacing: .titleSpacing) {
                    Text("weekly.summary.overall.kicker")
                        .font(.caption2.weight(.bold))
                        .tracking(.kickerTracking)
                        .foregroundStyle(theme.accent)

                    Text("weekly.summary.overall.title")
                        .font(.title3.weight(.bold))
                }

                Spacer()

                Text(score.performanceEmoji)
                    .font(.system(size: .emojiSize))
                    .accessibilityHidden(true)
            }

            HStack(spacing: 0) {
                metric(
                    value: score.completedCount.formatted(),
                    title: "weekly.summary.overall.completed"
                )

                Divider()

                metric(
                    value: score.totalCount.formatted(),
                    title: "weekly.summary.overall.total"
                )

                Divider()

                metric(
                    value: score.completionPercentage.formatted(
                        .percent.precision(.fractionLength(0))
                    ),
                    title: "weekly.summary.overall.rate"
                )
            }
            .frame(height: .metricsHeight)

            ProgressView(value: score.completionPercentage)
                .tint(theme.accent)
        }
        .padding(.cardPadding)
        .frame(maxWidth: .maximumWidth)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: .cornerRadius)
                .stroke(.primary.opacity(.borderOpacity), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("weeklySummary.overall.card")
    }

    private func metric(value: String, title: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: .metricSpacing) {
            Text(value)
                .font(.headline.monospacedDigit().weight(.bold))

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .metricHorizontalPadding)
    }
}

private extension CGFloat {
    static let maximumWidth = 720.0
    static let cardPadding = 18.0
    static let cornerRadius = 20.0
    static let contentSpacing = 14.0
    static let headerSpacing = 12.0
    static let titleSpacing = 3.0
    static let kickerTracking = 1.1
    static let emojiSize = 38.0
    static let metricSpacing = 2.0
    static let metricHorizontalPadding = 10.0
    static let metricsHeight = 42.0
}

private extension Double {
    static let borderOpacity = 0.06
}
