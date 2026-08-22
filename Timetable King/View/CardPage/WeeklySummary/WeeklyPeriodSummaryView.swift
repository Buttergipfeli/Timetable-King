import SwiftUI

struct WeeklyPeriodSummaryView: View {
    @Environment(\.appTheme) private var theme

    let title: String
    let score: CompletionScore

    var body: some View {
        VStack(alignment: .leading, spacing: .contentSpacing) {
            HStack(alignment: .center, spacing: .headerSpacing) {
                VStack(alignment: .leading, spacing: .titleSpacing) {
                    Text(title)
                        .font(.headline.weight(.bold))

                    Text("weekly.summary.score".localized(score.completedCount, score.totalCount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(score.completionPercentage, format: .percent.precision(.fractionLength(0)))
                    .font(.subheadline.monospacedDigit().weight(.bold))
                    .foregroundStyle(theme.accent)

                Text(score.performanceEmoji)
                    .font(.title2)
                    .accessibilityHidden(true)
            }

            ProgressView(value: score.completionPercentage)
                .tint(theme.accent)
        }
        .padding(.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadius)
                .fill(Color(.systemBackground))
        )
        .accessibilityElement(children: .combine)
    }
}

private extension CGFloat {
    static let cardPadding = 14.0
    static let cornerRadius = 16.0
    static let contentSpacing = 10.0
    static let headerSpacing = 10.0
    static let titleSpacing = 3.0
}
