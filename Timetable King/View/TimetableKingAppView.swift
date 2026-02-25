import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @State private var viewModel = TimetableKingAppViewModel(modelContainerService: .shared)
    
    var body: some View {
        ScrollView {
            VStack {
                CardView(isEmpty: viewModel.weekdayHabits.isEmpty) {
                    ForEach(viewModel.weekdayHabits) { weekdayHabit in
                        CardWeekdayHabitEntryView(weekdayHabit: weekdayHabit)
                    }
                }
                
                CardView(isEmpty: viewModel.resultsByWeekday.isEmpty) {
                    ForEach(viewModel.resultsByWeekday) { resultsForWeekday in
                        CardWeekdayHabitResultsView(resultsForWeekday: resultsForWeekday)
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
