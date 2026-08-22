import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.namespace) private var namespace
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppPaletteStore.self) private var paletteStore

    @State private var viewModel = TimetableKingAppViewModel(modelContainerService: .shared)

    var body: some View {
        @Bindable var vm = viewModel

        content
            .environment(\.appTheme, theme)
            .tint(theme.accent)
            .onChange(of: scenePhase, initial: true) { _, newPhase in
                guard newPhase == .active else { return }
                viewModel.refreshForActivation()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                viewModel.refreshForActivation()
            }
            .alert("common.operation.error.title", isPresented: $vm.isShowingOperationError) {
                Button("common.ok", role: .cancel) {}
            } message: {
                Text("common.operation.error.message")
            }
    }

    private var content: some View {
        NavigationStack {
            DashboardView(
                snapshot: viewModel.dashboardSnapshot,
                namespace: namespace,
                onOpenToday: { viewModel.open(card: .todayTasks) },
                onOpenWeeklySummary: { viewModel.open(card: .weeklySummary) },
                onOpenWeeklyTasks: { viewModel.open(card: .weeklyTasks) },
                onOpenSettings: { viewModel.isShowingSettings = true },
                onAddTask: { viewModel.isAddingWeeklyTask = true },
                onOpenEntry: viewModel.open,
                onSelectStatus: viewModel.updateTodayTaskStatus
            )
        }
        .sheet(item: $viewModel.presentedEntry) { entry in
            NavigationStack {
                TodayTaskDetailView(
                    showCloseButton: true,
                    allowsStatusEditing: true,
                    entry: entry,
                    onUpdateStatus: viewModel.updateTodayTaskStatus
                )
            }
        }
        .sheet(isPresented: $viewModel.isShowingSettings) {
            SettingsView(onDeleteHistory: viewModel.deleteHistory)
        }
        .sheet(isPresented: $viewModel.isAddingWeeklyTask) {
            AddWeeklyTaskView(
                preselectedWeekday: .current,
                onSave: viewModel.addWeeklyTask
            )
        }
        .fullScreenCover(item: $viewModel.presentedReviewSession) { session in
            TodayTaskReviewView(
                session: session,
                onResolve: viewModel.setTodayTaskStatus(for:status:),
                onFinish: viewModel.dismissReviewSession
            )
        }
        .fullScreenCover(isPresented: $viewModel.isCardPresented) {
            presentedCard
        }
    }

    @ViewBuilder
    private var presentedCard: some View {
        if let presentedCard = viewModel.presentedCard {
            switch presentedCard {
            case .todayTasks:
                TodayTasksView(
                    allowsStatusEditing: true,
                    onUpdateStatus: viewModel.updateTodayTaskStatus,
                    todayDigest: viewModel.todayDigest
                )
                .navigationTransition(id: presentedCard.transitionID, in: namespace)
            case .weeklySummary:
                WeeklySummaryView(onUpdateStatus: viewModel.updateTodayTaskStatus)
                    .navigationTransition(id: presentedCard.transitionID, in: namespace)
            case .weeklyTasks:
                WeeklyTasksView(
                    weekdayDigests: viewModel.weeklyTaskDigests,
                    initialWeekday: nil,
                    onAddTask: viewModel.addWeeklyTask,
                    onDeleteTask: viewModel.deleteWeeklyTask,
                    onUpdateTask: viewModel.updateWeeklyTask
                )
                .navigationTransition(id: presentedCard.transitionID, in: namespace)
            }
        }
    }

    private var theme: AppTheme {
        paletteStore.palette.theme(for: colorScheme)
    }
}

#Preview {
    TimetableKingAppView()
        .environment(AppPaletteStore())
}
