import SwiftUI

struct WeeklyTaskEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = WeeklyTaskEditViewModel()

    let habit: WeekdayHabit
    let onSave: (WeekdayHabit, String, Weekday, Int, Int) -> Bool
    let onDelete: (WeekdayHabit) -> Bool

    var body: some View {
        @Bindable var vm = viewModel

        Form {
            Section {
                TextField("timetable.weekly.tasks.add.placeholder", text: $vm.title)
            } header: {
                Text("timetable.weekly.tasks.add.task.title")
            }

            Section {
                Picker("timetable.weekly.tasks.add.weekday", selection: $vm.weekday) {
                    ForEach(Weekday.allCases, id: \.self) { day in
                        Text(day.label).tag(day)
                    }
                }

                DatePicker(
                    "timetable.weekly.tasks.add.time",
                    selection: $vm.time,
                    displayedComponents: .hourAndMinute
                )
            } header: {
                Text("timetable.weekly.tasks.add.schedule")
            }

            Section {
                Button("timetable.weekly.tasks.edit.delete", role: .destructive) {
                    if onDelete(habit) {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(habit.habit.title)
        .navigationBarTitleDisplayMode(.inline)
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
            }
        }
        .onAppear {
            viewModel.setup(habit: habit)
        }
    }
}
