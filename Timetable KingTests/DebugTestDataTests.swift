import Foundation
import SwiftData
import Testing
@testable import Timetable_King

@MainActor
struct DebugTestDataTests {
    @Test
    func providesMorningTasksExceptTuesdayAndReviewEntry() throws {
        let container = try makeSeededContainer()
        let context = container.mainContext

        let allTasks = try context.fetch(FetchDescriptor<WeekdayHabit>())
        let morningTasks = allTasks.filter {
            $0.habit.title == "Morning routine"
        }

        let expectedWeekdays = Set(Weekday.allCases.filter { $0 != .tuesday })

        #expect(morningTasks.count == expectedWeekdays.count)
        #expect(Set(morningTasks.map(\.weekday)) == expectedWeekdays)
        #expect(morningTasks.allSatisfy { $0.hour == 8 && $0.minute == 0 })
        #expect(allTasks.contains { $0.weekday == .tuesday } == false)

        let weekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let monday = try #require(
            Calendar.current.date(
                byAdding: .day,
                value: Weekday.monday.dayOffset(from: Weekday(date: weekStart)),
                to: weekStart
            )
        )
        let referenceDate = try #require(
            Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: monday)
        )
        let service = TodayTaskReviewService(
            modelContainerService: ModelContainerService(container: container)
        )
        let reviewEntries = service.fetchPendingReviewEntries(referenceDate: referenceDate)

        #expect(reviewEntries.contains { $0.habit.habit.title == "Morning routine" })
    }

    @Test
    func providesSevenSaturdayTasksAcrossRequestedTimeRanges() throws {
        let container = try makeSeededContainer()
        let saturdayTasks = try container.mainContext
            .fetch(FetchDescriptor<WeekdayHabit>())
            .filter { $0.weekday == .saturday }
        let tasksAfterTenPM = saturdayTasks.filter {
            $0.hour > 22 || ($0.hour == 22 && $0.minute > 0)
        }
        let tasksBeforeSixPM = saturdayTasks.filter { $0.hour < 18 }

        #expect(saturdayTasks.count == 7)
        #expect(tasksAfterTenPM.count == 3)
        #expect(tasksBeforeSixPM.count == 4)
        #expect(saturdayTasks.count == tasksAfterTenPM.count + tasksBeforeSixPM.count)
    }

    @Test
    func providesTwoHundredPastWeeksForHistoryStressTesting() throws {
        let container = try makeSeededContainer()
        let service = WeekdayDigestService(
            modelContainerService: ModelContainerService(container: container)
        )
        let intervals = service.fetchAvailableWeekIntervals()
        let currentWeekStart = try #require(Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start)
        let pastWeeks = intervals.filter { $0.start < currentWeekStart }
        let expectedOldestWeek = try #require(
            Calendar.current.date(byAdding: .weekOfYear, value: -200, to: currentWeekStart)
        )

        #expect(pastWeeks.count == 200)
        #expect(intervals.count == 201)
        #expect(pastWeeks.map(\.start).min() == expectedOldestWeek)
    }

    private func makeSeededContainer() throws -> ModelContainer {
        let schema = Schema([
            Habit.self,
            WeekdayHabit.self,
            WeekdayHabitResult.self,
            HistoryState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        Timetable_KingApp.setUpTestData(into: container.mainContext)
        try container.mainContext.save()
        return container
    }
}
