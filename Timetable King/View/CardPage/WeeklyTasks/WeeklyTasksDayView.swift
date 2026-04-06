import SwiftUI

struct WeeklyTasksDayView: View {
    @State private var viewModel = WeeklyTasksDayViewModel()

    var showCloseButton: Bool = false

    let digest: WeekdayDigest
    let onAddTask: (String, Weekday, Int, Int) -> Void

    var body: some View {
        ScrollView {
            if viewModel.habits.isEmpty {
                ContentUnavailableView(
                    "timetable.weekly.tasks.day.empty.title",
                    systemImage: "checkmark.circle",
                    description: Text("timetable.weekly.tasks.day.empty.message")
                )
                .padding(.top, .emptyStatePadding)
            } else {
                VStack(spacing: .rowSpacing) {
                    ForEach(viewModel.habits) { habit in
                        NavigationLink(value: habit) {
                            WeeklyTaskRowView(habit: habit)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, .screenPadding)
                .padding(.vertical, .screenVerticalPadding)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(digest.weekday.label)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: WeekdayHabit.self) { habit in
            WeeklyTaskDetailView(habit: habit)
        }
        .toolbar {
            if showCloseButton {
                DismissToolbarItem()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isAddingTask = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isAddingTask) {
            AddWeeklyTaskView(preselectedWeekday: digest.weekday, onSave: onAddTask)
        }
        .onChange(of: digest, initial: true) {
            viewModel.map(digest: digest)
        }
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let rowSpacing = 12.0
    static let emptyStatePadding = 60.0
}
