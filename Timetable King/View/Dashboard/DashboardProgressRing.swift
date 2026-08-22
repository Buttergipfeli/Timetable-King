import SwiftUI

struct DashboardProgressRing: View {
    @Environment(\.appTheme) private var theme

    let completedCount: Int
    let totalCount: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(.primary.opacity(.trackOpacity), lineWidth: .lineWidth)

            Circle()
                .trim(from: 0, to: max(progress, .minimumVisibleProgress))
                .stroke(theme.accent, style: StrokeStyle(lineWidth: .lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text(progress, format: .percent.precision(.fractionLength(0)))
                    .font(.caption.weight(.bold))

                Text("dashboard.progress.label")
                    .font(.system(size: .labelFontSize, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: .ringSize, height: .ringSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("dashboard.today.progress.accessibility")
        .accessibilityValue("\(completedCount) / \(totalCount)")
    }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

private extension CGFloat {
    static let ringSize = 76.0
    static let lineWidth = 7.0
    static let labelFontSize = 8.0
}

private extension Double {
    static let trackOpacity = 0.1
    static let minimumVisibleProgress = 0.002
}
