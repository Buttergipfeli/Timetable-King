import SwiftUI

struct WeeklySummaryView: View {
    @State private var viewModel = WeeklySummaryViewModel()

    var onUpdateStatus: ((TodayTaskEntry, HabitState) -> Bool)? = nil

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            TabView(selection: $vm.currentWeekIndex) {
                ForEach(Array(viewModel.availableWeeks.enumerated()), id: \.offset) { index, week in
                    WeekPageView(
                        weekInterval: week,
                        entries: viewModel.entries(for: week)
                    )
                    .tag(index)
                    .onAppear { viewModel.loadDigests(for: week) }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "timetable.weekly.summary.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: WeeklySummaryEntry.self) { entry in
                TodayTasksView(
                    title: entry.digest.weekday.label,
                    embedsNavigationStack: false,
                    allowsStatusEditing: entry.isCurrentDay,
                    onUpdateStatus: entry.isCurrentDay ? { task, status in
                        guard onUpdateStatus?(task, status) == true else { return false }
                        viewModel.reloadDigests(forWeekStartingAt: entry.weekStart)
                        return true
                    } : nil,
                    todayDigest: entry.digest
                )
            }
            .toolbar { DismissToolbarItem() }
        }
        .onAppear { viewModel.loadAvailableWeeks() }
    }
}

private struct WeekPageView: View {
    let weekInterval: DateInterval
    let entries: [WeeklySummaryEntry]

    var body: some View {
        ScrollView {
            VStack(spacing: .rowSpacing) {
                Text(weekLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(entries) { entry in
                    NavigationLink(value: entry) {
                        WeeklySummaryRowView(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, .screenPadding)
            .padding(.vertical, .screenVerticalPadding)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var weekLabel: String {
        let currentWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: .now)?.start
        let lastWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart ?? .now)

        if let currentWeekStart,
           Calendar.current.isDate(weekInterval.start, inSameDayAs: currentWeekStart) {
            return String(localized: "weekly.summary.current.week")
        }

        if let lastWeekStart,
           Calendar.current.isDate(weekInterval.start, inSameDayAs: lastWeekStart) {
            return String(localized: "weekly.summary.last.week")
        }

        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: weekInterval.start, to: weekInterval.end - 1)
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let rowSpacing = 12.0
}
