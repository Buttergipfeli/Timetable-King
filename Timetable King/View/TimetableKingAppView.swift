import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @State private var viewModel = TimetableKingAppViewModel(modelContainerService: .shared)
    
    var body: some View {
        ScrollView {
            VStack {
                CardView(isEmpty: viewModel.todayHabits.isEmpty, title: "timetable.card.today.tasks") {
                    ForEach(viewModel.todayHabits) { weekdayHabit in
                        CardWeekdayHabitEntryView(weekdayHabit: weekdayHabit)
                    }
                }
//                .matchedTransitionSource(id: transitionID, in: navigationTransitionNamespace)
//                .fullScreenCover(isPresented: $isPresented) {
//                    Color.green
//                        .overlay {
//                            Button {
//                                isPresented = false
//                            } label: {
//                                Text("timetable.transition.title")
//                            }
//                        }
//                        .navigationTransition(id: transitionID, in: navigationTransitionNamespace)
//                }
                
                CardView(isEmpty: viewModel.activeWeekdayDigests.isEmpty, title: "timetable.card.weekly.summary") {
                    ForEach(viewModel.activeWeekdayDigests) { weekdayDigest in
                        CardWeekdayHabitResultsView(weekdayDigest: weekdayDigest)
                    }
                }
                
                CardView(isEmpty: viewModel.activeWeekdayDigests.isEmpty, title: "timetable.card.my.weekly.tasks") {
                    ForEach(viewModel.activeWeekdayDigests) { weekdayDigest in
                        CardWeeklyTasksEntryView(weekday: weekdayDigest.weekday, tasksForWeekdayCount: weekdayDigest.habits.count)
                    }
                }
            }
            .padding(.containerPadding)
        }
        .task {
            viewModel.load()
        }
    }
}

private extension CGFloat {
    static let containerPadding = 16.0
}

#Preview {
    TimetableKingAppView()
}
