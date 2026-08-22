import SwiftUI

struct DashboardTodayOverviewView: View {
    @Environment(\.appTheme) private var theme

    let snapshot: DashboardSnapshot
    let onOpenNextTask: (TodayTaskEntry) -> Void

    var body: some View {
        DashboardSurface {
            VStack(alignment: .leading, spacing: .sectionSpacing) {
                HStack(alignment: .top, spacing: .contentSpacing) {
                    VStack(alignment: .leading, spacing: .titleSpacing) {
                        Text("dashboard.today.kicker")
                            .font(.caption2.weight(.bold))
                            .tracking(.kickerTracking)
                            .foregroundStyle(theme.accent)

                        Text("dashboard.today.title")
                            .font(.title2.weight(.bold))
                            .multilineTextAlignment(.leading)

                        Text("dashboard.today.progress.label")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: .minimumSpacer)

                    DashboardProgressRing(
                        completedCount: snapshot.completedTodayCount,
                        totalCount: snapshot.totalTodayCount
                    )
                }

                Divider()

                nextTask
            }
            .padding(.cardPadding)
        }
    }

    @ViewBuilder
    private var nextTask: some View {
        if let entry = snapshot.nextTask {
            Button {
                onOpenNextTask(entry)
            } label: {
                nextTaskContent(entry: entry)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("dashboard.open.details")
        } else {
            nextTaskContent(entry: nil)
        }
    }

    private func nextTaskContent(entry: TodayTaskEntry?) -> some View {
        HStack(spacing: .nextTaskSpacing) {
            Image(systemName: entry == nil ? "checkmark.circle" : "clock")
                .foregroundStyle(theme.accent)

            VStack(alignment: .leading, spacing: .nextTaskTitleSpacing) {
                Text("dashboard.today.next.task")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(entry?.title ?? "dashboard.today.no.open.tasks".localized)
                    .font(.subheadline.weight(.semibold))
            }

            Spacer()

            if let entry {
                Text(entry.timeString)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(theme.accent)
                    .padding(.horizontal, .timeHorizontalPadding)
                    .padding(.vertical, .timeVerticalPadding)
                    .background(theme.accentSurface, in: Capsule())

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

private extension CGFloat {
    static let cardPadding = 20.0
    static let sectionSpacing = 16.0
    static let contentSpacing = 16.0
    static let titleSpacing = 6.0
    static let minimumSpacer = 12.0
    static let nextTaskSpacing = 10.0
    static let nextTaskTitleSpacing = 2.0
    static let timeHorizontalPadding = 10.0
    static let timeVerticalPadding = 6.0
}

private extension CGFloat {
    static let kickerTracking = 1.2
}
