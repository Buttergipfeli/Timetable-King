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
            }
            .padding(.containerPadding)
        }
    }
}

private extension CGFloat {
    static let containerPadding = 16.0
}

#Preview {
    TimetableKingAppView()
}
