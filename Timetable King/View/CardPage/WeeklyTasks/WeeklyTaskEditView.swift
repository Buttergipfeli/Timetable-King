import SwiftUI

struct WeeklyTaskEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = WeeklyTaskEditViewModel()
    @State private var isShowingDeleteConfirmation = false

    let habit: WeekdayHabit
    let onSave: (WeekdayHabit, String, Set<Weekday>, Int, Int, TaskReminder) -> Bool
    let onDelete: (WeekdayHabit) -> Bool

    var body: some View {
        @Bindable var vm = viewModel

        Form {
            Section {
                TextField("timetable.weekly.tasks.add.placeholder", text: $vm.title)
                    .accessibilityIdentifier("weeklyTask.edit.title.field")
            } header: {
                Text("timetable.weekly.tasks.add.task.title")
            }

            Section {
                WeekdaySelectionView(selection: $vm.weekdays)
            } header: {
                Text("timetable.weekly.tasks.add.repeat")
            } footer: {
                Text("timetable.weekly.tasks.edit.repeat.description")
            }

            Section {
                DatePicker(
                    "timetable.weekly.tasks.add.time",
                    selection: $vm.time,
                    displayedComponents: .hourAndMinute
                )
            } header: {
                Text("timetable.weekly.tasks.add.schedule")
            }

            TaskReminderSection(reminder: $vm.reminder)

            Section {
                Button("timetable.weekly.tasks.edit.delete", role: .destructive) {
                    isShowingDeleteConfirmation = true
                }
                .accessibilityIdentifier("weeklyTask.delete.button")
            } footer: {
                Text("timetable.weekly.tasks.edit.delete.description")
            }
        }
        .navigationTitle(habit.habit.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "task.delete.confirmation.title",
            isPresented: $isShowingDeleteConfirmation
        ) {
            Button("task.delete.confirm", role: .destructive) {
                if onDelete(habit) { dismiss() }
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("task.delete.confirmation.message")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if viewModel.save(habit: habit, onSave: onSave) {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.semibold))
                }
                .disabled(!viewModel.isSaveable)
                .accessibilityIdentifier("weeklyTask.edit.save.button")
            }
        }
        .onAppear {
            viewModel.setup(habit: habit)
        }
    }
}
