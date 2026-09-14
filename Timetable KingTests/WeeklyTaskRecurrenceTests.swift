import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct WeeklyTaskRecurrenceTests {
    @Test
    func savesTaskForEverySelectedWeekday() throws {
        let service = try makeModelContainerService()
        let selectedWeekdays: Set<Weekday> = [.monday, .wednesday, .friday]

        try WeeklyTaskService(modelContainerService: service).save(
            title: "Training",
            weekdays: selectedWeekdays,
            hour: 18,
            minute: 30
        )

        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(schedules.count == selectedWeekdays.count)
        #expect(Set(schedules.map(\.weekday)) == selectedWeekdays)
        #expect(Set(schedules.map(\.habit.title)) == ["Training"])
        #expect(schedules.allSatisfy { $0.hour == 18 && $0.minute == 30 })
    }

    @Test
    func rejectsBatchWhenOneSelectedScheduleAlreadyExists() throws {
        let service = try makeModelContainerService()
        let taskService = WeeklyTaskService(modelContainerService: service)
        try taskService.save(title: "Training", weekday: .monday, hour: 18, minute: 0)

        var didThrow = false
        do {
            try taskService.save(
                title: "Training",
                weekdays: [.monday, .wednesday],
                hour: 18,
                minute: 0
            )
        } catch {
            didThrow = true
            service.context.rollback()
        }

        let schedules = try service.context.fetch(FetchDescriptor<WeekdayHabit>())
        #expect(didThrow)
        #expect(schedules.count == 1)
        #expect(schedules.first?.weekday == .monday)
    }

    @Test
    func requiresTitleAndAtLeastOneWeekday() {
        let viewModel = AddWeeklyTaskViewModel()
        viewModel.title = "Read"
        viewModel.weekdays = []

        #expect(!viewModel.isSaveable)

        viewModel.weekdays = [.tuesday, .thursday]

        #expect(viewModel.isSaveable)
    }

    private func makeModelContainerService() throws -> ModelContainerService {
        let schema = Schema([
            Habit.self,
            WeekdayHabit.self,
            WeekdayHabitResult.self,
            HistoryState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContainerService(container: container)
    }
}
