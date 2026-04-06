import SwiftUI

struct AddWeeklyTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AddWeeklyTaskViewModel()

    let preselectedWeekday: Weekday?
    let onSave: (String, Weekday, Int, Int) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("timetable.weekly.tasks.add.placeholder", text: $viewModel.title)
                } header: {
                    Text("timetable.weekly.tasks.add.task.title")
                }

                Section {
                    Picker("timetable.weekly.tasks.add.weekday", selection: $viewModel.weekday) {
                        ForEach(Weekday.allCases, id: \.self) { day in
                            Text(day.label).tag(day)
                        }
                    }

                    DatePicker(
                        "timetable.weekly.tasks.add.time",
                        selection: $viewModel.time,
                        displayedComponents: .hourAndMinute
                    )
                } header: {
                    Text("timetable.weekly.tasks.add.schedule")
                }
            }
            .navigationTitle("timetable.weekly.tasks.add.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("timetable.weekly.tasks.add.cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("timetable.weekly.tasks.add.save") {
                        viewModel.save(onSave: onSave)
                        dismiss()
                    }
                    .disabled(!viewModel.isSaveable)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            viewModel.setup(preselectedWeekday: preselectedWeekday)
        }
    }
}
