import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @State private var viewModel = TimetableKingAppViewModel(modelContainerService: .shared)
    
    @Environment(\.namespace) private var namespace
    
    var body: some View {
        ScrollView {
            VStack {
                CardView(
                    isEmpty: viewModel.todayDigests?.habits.isEmpty == true,
                    title: "timetable.card.today.tasks"
                ) {
                    viewModel.open(card: .todayTasks)
                } content: {
                    ForEach(viewModel.todayDigests?.habits ?? []) { weekdayHabit in
                        CardWeekdayHabitEntryView(weekdayHabit: weekdayHabit)
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
                        CardWeekdayHabitResultsView(weekdayDigest: weekdayDigest)
                    }
                }
                .matchedTransitionSource(id: .weeklySummaryID, in: namespace)
                
                CardView(
                    isEmpty: viewModel.activeWeekdayDigests.isEmpty,
                    title: "timetable.card.my.weekly.tasks"
                ) {
                    viewModel.open(card: .weeklyTasks)
                } content: {
                    ForEach(viewModel.activeWeekdayDigests) { weekdayDigest in
                        CardWeeklyTasksEntryView(weekday: weekdayDigest.weekday, tasksForWeekdayCount: weekdayDigest.habits.count)
                    }
                }
                .matchedTransitionSource(id: .weeklyTasksID, in: namespace)
            }
            .padding(.containerPadding)
        }
        .fullScreenCover(isPresented: $viewModel.isCardPresented) {
            if let presentedCard = viewModel.presentedCard {
                switch presentedCard {
                case .todayTasks:
                    Text("today")
                        .navigationTransition(id: .todayTasksID, in: namespace)
                case .weeklySummary:
                    Text("summary")
                        .navigationTransition(id: .weeklySummaryID, in: namespace)
                case .weeklyTasks:
                    Text("tasks")
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
