import SwiftUI

struct DashboardView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let snapshot: DashboardSnapshot
    let namespace: Namespace.ID?
    let onOpenToday: () -> Void
    let onOpenWeeklySummary: () -> Void
    let onOpenWeeklySummaryWeekday: (Weekday) -> Void
    let onOpenWeeklyTasks: () -> Void
    let onOpenSettings: () -> Void
    let onAddTask: () -> Void
    let onOpenEntry: (TodayTaskEntry) -> Void
    let onSelectStatus: (TodayTaskEntry, HabitState) -> Bool

    var body: some View {
        ScrollView {
            VStack(spacing: .sectionSpacing) {
                DashboardHeaderView(date: .now, onOpenSettings: onOpenSettings)
                    .padding(.bottom, .headerBottomPadding)

                DashboardTodayOverviewView(
                    snapshot: snapshot,
                    onOpenNextTask: onOpenEntry
                )

                if horizontalSizeClass == .regular {
                    regularContent
                } else {
                    compactContent
                }
            }
            .frame(maxWidth: .maximumContentWidth)
            .padding(.horizontal, .horizontalPadding)
            .padding(.top, .topPadding)
            .padding(.bottom, .bottomPadding)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var compactContent: some View {
        VStack(spacing: .sectionSpacing) {
            todayTasks

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: .sectionSpacing) {
                    weeklySummary
                    weeklyPlan
                }

                VStack(spacing: .sectionSpacing) {
                    weeklySummary
                    weeklyPlan
                }
            }

            DashboardAddTaskButton(action: onAddTask)
        }
    }

    private var regularContent: some View {
        HStack(alignment: .top, spacing: .sectionSpacing) {
            todayTasks
                .frame(maxWidth: .infinity)

            VStack(spacing: .sectionSpacing) {
                weeklySummary
                weeklyPlan
                DashboardAddTaskButton(action: onAddTask)
            }
            .frame(maxWidth: .sideColumnWidth)
        }
    }

    private var todayTasks: some View {
        DashboardTodayTasksView(
            entries: snapshot.todayEntries,
            onOpenEntry: onOpenEntry,
            onSelectStatus: onSelectStatus,
            onShowAll: onOpenToday,
            onAddTask: onAddTask
        )
        .matchedTransitionSource(id: CardPage.todayTasks.transitionID, in: namespace)
    }

    private var weeklySummary: some View {
        DashboardWeeklySummaryView(
            snapshot: snapshot,
            onOpenSummary: onOpenWeeklySummary,
            onOpenWeekday: onOpenWeeklySummaryWeekday
        )
            .matchedTransitionSource(id: CardPage.weeklySummary.transitionID, in: namespace)
    }

    private var weeklyPlan: some View {
        DashboardWeeklyPlanView(snapshot: snapshot, onOpen: onOpenWeeklyTasks)
            .matchedTransitionSource(id: CardPage.weeklyTasks.transitionID, in: namespace)
    }
}

private extension CGFloat {
    static let sectionSpacing = 14.0
    static let headerBottomPadding = 4.0
    static let maximumContentWidth = 920.0
    static let sideColumnWidth = 360.0
    static let horizontalPadding = 16.0
    static let topPadding = 12.0
    static let bottomPadding = 28.0
}
