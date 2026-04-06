import SwiftUI

struct TodayTaskStatusBadge: View {
    let entry: TodayTaskEntry

    var body: some View {
        Text(entry.statusTitle)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, .badgeHorizontalPadding)
            .padding(.vertical, .badgeVerticalPadding)

            .background(entry.statusColor, in: Capsule())
    }
}

private extension TodayTaskEntry {
    var statusColor: Color {
        switch status {
        case .done:
            .green
        case .failed:
            .red
        case .none:
            .gray
        }
    }
}

private extension CGFloat {
    static let badgeHorizontalPadding = 12.0
    static let badgeVerticalPadding = 8.0
}
