import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @State private var viewModel = TimetableKingAppViewModel(modelContainerService: .shared)
    
    var body: some View {
        ScrollView {
            VStack {
                CardView(isEmpty: viewModel.todayHabits.isEmpty) {
                    ForEach(viewModel.todayHabits) { weekdayHabit in
                        CardWeekdayHabitEntryView(weekdayHabit: weekdayHabit)
                    }
                }
                
                CardView(isEmpty: viewModel.nonEmptyHabitablesForWeekdays.isEmpty) {
                    ForEach(viewModel.nonEmptyHabitablesForWeekdays) { habitablesForWeekday in
                        CardWeekdayHabitResultsView(habitablesForWeekday: habitablesForWeekday)
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
