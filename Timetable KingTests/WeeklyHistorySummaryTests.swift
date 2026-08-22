import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct WeeklyHistorySummaryTests {
    @Test
    func mapsCompletionPercentagesToSharedPerformanceEmojis() {
        let scores = [
            (CompletionScore(completedCount: 0, totalCount: 0), "😶"),
            (CompletionScore(completedCount: 0, totalCount: 4), "😭"),
            (CompletionScore(completedCount: 1, totalCount: 8), "😢"),
            (CompletionScore(completedCount: 1, totalCount: 4), "😬"),
            (CompletionScore(completedCount: 2, totalCount: 4), "🙂"),
            (CompletionScore(completedCount: 3, totalCount: 4), "😄"),
            (CompletionScore(completedCount: 4, totalCount: 4), "🤩")
        ]

        for (score, expectedEmoji) in scores {
            #expect(score.performanceEmoji == expectedEmoji)
        }
    }

    @Test
    func aggregatesScoresAcrossEveryAvailableWeek() async throws {
        let service = try makeModelContainerService()
        let context = service.context
        let currentWeek = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now))
        let previousWeekStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek.start)
        )
        let twoWeeksAgoStart = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -2, to: currentWeek.start)
        )
        let habit = Habit(title: "Morning routine")
        let schedule = WeekdayHabit(
            hour: 8,
            minute: 0,
            weekdayRawValue: Weekday.monday.rawValue,
            habit: habit
        )
        schedule.createdAt = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -1, to: twoWeeksAgoStart)
        )

        context.insert(habit)
        context.insert(schedule)
        context.insert(
            WeekdayHabitResult(
                day: try #require(date(for: .monday, inWeekStartingAt: twoWeeksAgoStart)),
                weekdayHabit: schedule,
                status: .done
            )
        )
        context.insert(
            WeekdayHabitResult(
                day: try #require(date(for: .monday, inWeekStartingAt: previousWeekStart)),
                weekdayHabit: schedule,
                status: .failed
            )
        )
        try context.save()

        let viewModel = WeeklySummaryViewModel(modelContainerService: service)
        await viewModel.loadAvailableWeeks()

        #expect(viewModel.availableWeeks.count == 3)
        #expect(viewModel.digestsByWeek.count == 1)
        #expect(viewModel.overallScore.completedCount == 1)
        #expect(viewModel.overallScore.totalCount == 3)
        #expect(viewModel.overallScore.performanceEmoji == "😬")
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

    private func date(for weekday: Weekday, inWeekStartingAt weekStart: Date) -> Date? {
        Calendar.current.date(
            byAdding: .day,
            value: weekday.dayOffset(from: Weekday(date: weekStart)),
            to: weekStart
        )
    }
}
