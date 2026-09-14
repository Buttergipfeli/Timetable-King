import SwiftUI

struct WeeklyTasksView: View {
    @State private var viewModel = WeeklyTasksViewModel()

    let weekdayDigests: [WeekdayDigest]
    let initialWeekday: Weekday?
    let onAddTask: (String, Set<Weekday>, Int, Int) -> Bool
    let onDeleteTask: (WeekdayHabit) -> Bool
    let onUpdateTask: (WeekdayHabit, String, Weekday, Int, Int) -> Bool

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ScrollView {
                VStack(spacing: .rowSpacing) {
                    ForEach(viewModel.weekdayDigests) { digest in
                        NavigationLink(value: digest.weekday) {
                            WeeklyTasksDayRowView(digest: digest)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, .screenPadding)
                .padding(.vertical, .screenVerticalPadding)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("timetable.weekly.tasks.title")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Weekday.self) { weekday in
                let digest = viewModel.weekdayDigests.first { $0.weekday == weekday } ?? WeekdayDigest(weekday: weekday, habits: [], results: [])
                WeeklyTasksDayView(digest: digest, onAddTask: onAddTask, onDeleteTask: onDeleteTask, onUpdateTask: onUpdateTask)
            }
            .toolbar {
                DismissToolbarItem()
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isAddingTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isAddingTask) {
            AddWeeklyTaskView(preselectedWeekday: nil, onSave: onAddTask)
        }
        .onChange(of: weekdayDigests, initial: true) {
            viewModel.map(weekdayDigests: weekdayDigests)
        }
        .onChange(of: initialWeekday, initial: true) { _, weekday in
            if let weekday { viewModel.path = [weekday] }
        }
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let rowSpacing = 12.0
}
