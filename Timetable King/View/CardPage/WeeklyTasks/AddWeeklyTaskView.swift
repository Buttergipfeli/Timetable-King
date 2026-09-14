import SwiftUI

struct AddWeeklyTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AddWeeklyTaskViewModel()

    let preselectedWeekday: Weekday?
    let onSave: (String, Set<Weekday>, Int, Int) -> Bool

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            Form {
                Section {
                    TextField("timetable.weekly.tasks.add.placeholder", text: $vm.title)
                        .accessibilityIdentifier("weeklyTask.add.title.field")
                } header: {
                    Text("timetable.weekly.tasks.add.task.title")
                }

                Section {
                    WeekdaySelectionView(selection: $vm.weekdays)
                } header: {
                    Text("timetable.weekly.tasks.add.repeat")
                } footer: {
                    Text("timetable.weekly.tasks.add.repeat.description")
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
            }
            .navigationTitle("timetable.weekly.tasks.add.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                DismissToolbarItem()
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.save(onSave: onSave) {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline.weight(.semibold))
                    }
                    .disabled(!viewModel.isSaveable)
                    .accessibilityIdentifier("weeklyTask.add.save.button")
                }
            }
        }
        .onAppear {
            viewModel.setup(preselectedWeekday: preselectedWeekday)
        }
    }
}
