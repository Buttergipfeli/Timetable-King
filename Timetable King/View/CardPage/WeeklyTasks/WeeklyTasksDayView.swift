import SwiftUI

struct WeeklyTasksDayView: View {
    @State private var viewModel = WeeklyTasksDayViewModel()

    var showCloseButton: Bool = false

    let digest: WeekdayDigest
    let onAddTask: (String, Weekday, Int, Int) -> Void
    let onDeleteTask: (WeekdayHabit) -> Void
    let onUpdateTask: (WeekdayHabit, String, Weekday, Int, Int) -> Void

    var body: some View {
        List {
            ForEach(viewModel.habits) { habit in
                Button {
                    viewModel.selectedHabit = habit
                } label: {
                    WeeklyTaskRowView(habit: habit)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color(.systemGroupedBackground))
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: .rowSpacing / 2, leading: .screenPadding, bottom: .rowSpacing / 2, trailing: .screenPadding))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDeleteTask(habit)
                    } label: {
                        Label("timetable.weekly.tasks.edit.delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .overlay {
            if viewModel.habits.isEmpty {
                ContentUnavailableView(
                    "timetable.weekly.tasks.day.empty.title",
                    systemImage: "checkmark.circle",
                    description: Text("timetable.weekly.tasks.day.empty.message")
                )
            }
        }
        .navigationTitle(digest.weekday.label)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $viewModel.selectedHabit) { habit in
            WeeklyTaskEditView(habit: habit, onSave: onUpdateTask, onDelete: onDeleteTask)
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
    static let rowSpacing = 12.0
}
