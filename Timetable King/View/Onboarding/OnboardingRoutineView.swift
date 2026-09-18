import SwiftUI

struct OnboardingRoutineView: View {
    @State private var viewModel = AddWeeklyTaskViewModel()
    @State private var isShowingSaveError = false

    let onSave: (String, Set<Weekday>, Int, Int, TaskReminder) -> Bool
    let onFinish: () -> Void

    var body: some View {
        @Bindable var vm = viewModel

        Form {
            Section {
                templateButton(
                    title: "onboarding.template.morning",
                    symbol: "sun.max",
                    hour: 8,
                    weekdays: Set(Weekday.allCases)
                )
                templateButton(
                    title: "onboarding.template.training",
                    symbol: "figure.run",
                    hour: 18,
                    weekdays: [.monday, .wednesday, .friday]
                )
                templateButton(
                    title: "onboarding.template.household",
                    symbol: "house",
                    hour: 10,
                    weekdays: [.saturday]
                )
            } header: {
                Text("onboarding.templates.title")
            } footer: {
                Text("onboarding.templates.description")
            }

            Section("timetable.weekly.tasks.add.task.title") {
                TextField("timetable.weekly.tasks.add.placeholder", text: $vm.title)
                    .accessibilityIdentifier("onboarding.routine.title.field")
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
            } footer: {
                Text("onboarding.routine.repeat")
            }
            TaskReminderSection(reminder: $vm.reminder)
        }
        .navigationTitle("onboarding.routine.title")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("onboarding.skip", action: onFinish)
                    .accessibilityIdentifier("onboarding.skip.button")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                if viewModel.save(onSave: onSave) {
                    onFinish()
                } else {
                    isShowingSaveError = true
                }
            } label: {
                Text("onboarding.routine.save")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 18))
            .disabled(!viewModel.isSaveable)
            .accessibilityIdentifier("onboarding.routine.save.button")
            .frame(maxWidth: 520)
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(.bar)
        }
        .alert("common.operation.error.title", isPresented: $isShowingSaveError) {
            Button("common.ok", role: .cancel) {}
        } message: {
            Text("common.operation.error.message")
        }
    }

    private func templateButton(
        title: String,
        symbol: String,
        hour: Int,
        weekdays: Set<Weekday>
    ) -> some View {
        Button {
            viewModel.title = title.localized
            viewModel.weekdays = weekdays
            viewModel.time = Calendar.current.date(
                bySettingHour: hour,
                minute: 0,
                second: 0,
                of: .now
            ) ?? .now
        } label: {
            Label(title.localized, systemImage: symbol)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .accessibilityIdentifier("\(title).button")
    }
}
