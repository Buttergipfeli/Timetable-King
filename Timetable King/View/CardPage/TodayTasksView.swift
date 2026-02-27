import SwiftUI

struct TodayTasksView: View {
    @State private var viewModel = TodayTasksViewModel()
    
    let todayDigest: WeekdayDigest?
    
    var body: some View {
        ScrollView {
            VStack(spacing: .sectionSpacing) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Finished")
                        Spacer()
                        Text("Status")
                    }
                    
                    ForEach(viewModel.finishedHabits.enumerated(), id: \.element) { index, finishedHabit in
                        HStack {
                            Text("\(finishedHabit.timeString)")
                            Text("\(finishedHabit.habit.title)")
                            Spacer()
                            Text("\(viewModel.finishedResults[index]?.isDone == true ? "✅" : "❌")")
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Todo")
                    
                    ForEach(viewModel.unfinishedHabits) { unFinishedHabit in
                        HStack {
                            Text("\(unFinishedHabit.timeString)")
                            Text("\(unFinishedHabit.habit.title)")
                            Spacer()
                            Text("?")
                        }
                    }
                }
            }
            .padding(.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: todayDigest, initial: true) {
            viewModel.map(todayDigest: todayDigest)
        }
    }
}

private extension CGFloat {
    static let padding = 16.0
    static let sectionSpacing = 32.0
}
