import SwiftUI

struct AddWeeklyTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AddWeeklyTaskViewModel()

    let preselectedWeekday: Weekday?
    let onSave: (String, Weekday, Int, Int) -> Bool

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
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
                }
            }
        }
        .onAppear {
            viewModel.setup(preselectedWeekday: preselectedWeekday)
        }
    }
}
