import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @Environment(\.namespace) private var namespace

    @State private var viewModel = TimetableKingAppViewModel(modelContainerService: .shared)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    CardView(
                        isEmpty: viewModel.todayDigest?.habits.isEmpty == true,
                        title: "timetable.card.today.tasks"
                    ) {
                        viewModel.open(card: .todayTasks)
                    } content: {
                        ForEach(viewModel.todayDigest?.habits ?? []) { weekdayHabit in
                            Button {
                                viewModel.open(habit: weekdayHabit)
                            } label: {
                                CardWeekdayHabitEntryView(weekdayHabit: weekdayHabit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .matchedTransitionSource(id: .todayTasksID, in: namespace)

                    CardView(
                        isEmpty: viewModel.activeWeekdayDigests.isEmpty,
                        title: "timetable.card.weekly.summary"
                    ) {
                        viewModel.open(card: .weeklySummary)
                    } content: {
                        ForEach(viewModel.activeWeekdayDigests) { weekdayDigest in
                            Button {
                                viewModel.openSummary(weekdayDigest: weekdayDigest)
                            } label: {
                                CardWeekdayHabitResultsView(weekdayDigest: weekdayDigest)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .matchedTransitionSource(id: .weeklySummaryID, in: namespace)

                    CardView(
                        isEmpty: viewModel.activeWeeklyTaskDigests.isEmpty,
                        title: "timetable.card.my.weekly.tasks"
                    ) {
                        viewModel.open(card: .weeklyTasks)
                    } content: {
                        ForEach(viewModel.activeWeeklyTaskDigests) { weekdayDigest in
                            Button {
                                viewModel.open(weekdayDigest: weekdayDigest)
                            } label: {
                                CardWeeklyTasksEntryView(weekday: weekdayDigest.weekday, tasksForWeekdayCount: weekdayDigest.habits.count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .matchedTransitionSource(id: .weeklyTasksID, in: namespace)
                }
                .padding(.containerPadding)
                .sheet(item: $viewModel.presentedSummaryDigest) { digest in
                    TodayTasksView(title: digest.weekday.label, todayDigest: digest)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isShowingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(item: $viewModel.presentedEntry) { entry in
            NavigationStack {
                TodayTaskDetailView(entry: entry, showCloseButton: true)
            }
        }
        .sheet(item: $viewModel.presentedWeekdayDigest) { digest in
            NavigationStack {
                WeeklyTasksDayView(
                    showCloseButton: true,
                    digest: digest,
                    onAddTask: viewModel.addWeeklyTask,
                    onDeleteTask: viewModel.deleteWeeklyTask,
                    onUpdateTask: viewModel.updateWeeklyTask
                )
            }
        }
        .sheet(isPresented: $viewModel.isShowingSettings) {
            SettingsView(onDeleteHistory: viewModel.deleteHistory)
        }
        .fullScreenCover(isPresented: $viewModel.isCardPresented) {
            if let presentedCard = viewModel.presentedCard {
                switch presentedCard {
                case .todayTasks:
                    TodayTasksView(todayDigest: viewModel.todayDigest)
                        .navigationTransition(id: .todayTasksID, in: namespace)
                case .weeklySummary:
                    WeeklySummaryView()
                        .navigationTransition(id: .weeklySummaryID, in: namespace)
                case .weeklyTasks:
                    WeeklyTasksView(
                        weekdayDigests: viewModel.weeklyTaskDigests,
                        initialWeekday: nil,
                        onAddTask: viewModel.addWeeklyTask,
                        onDeleteTask: viewModel.deleteWeeklyTask,
                        onUpdateTask: viewModel.updateWeeklyTask
                    )
                    .navigationTransition(id: .weeklyTasksID, in: namespace)
                }
            }
        }
        .task {
            viewModel.load()
        }
    }
}

private extension String {
    static let todayTasksID = "todayTasks"
    static let weeklySummaryID = "weeklySummary"
    static let weeklyTasksID = "weeklyTasks"
}

private extension CGFloat {
    static let containerPadding = 16.0
}

#Preview {
    TimetableKingAppView()
}
