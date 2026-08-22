import SwiftUI

struct WeeklySummaryView: View {
    @State private var viewModel = WeeklySummaryViewModel()
    @State private var isWeekPickerPresented = false
    @State private var selectedWeekIndex = 0

    var onUpdateStatus: ((TodayTaskEntry, HabitState) -> Bool)? = nil

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                OverallHistorySummaryView(score: viewModel.overallScore)
                    .redacted(reason: viewModel.isLoadingHistory ? .placeholder : [])
                    .padding(.horizontal, .overallHorizontalPadding)
                    .padding(.top, .overallTopPadding)

                TabView(selection: $vm.currentWeekIndex) {
                    ForEach(Array(viewModel.availableWeeks.enumerated()), id: \.offset) { index, week in
                        WeekPageView(
                            weekInterval: week,
                            score: viewModel.score(for: week),
                            entries: viewModel.entries(for: week)
                        )
                        .tag(index)
                        .onAppear { viewModel.loadDigests(for: week) }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                WeeklySummaryPageControl(
                    pageCount: viewModel.availableWeeks.count,
                    currentPage: $vm.currentWeekIndex,
                    onLongPress: presentWeekPicker
                )
                .frame(maxWidth: .pageControlMaximumWidth)
                .frame(height: .pageControlHeight)
                .padding(.top, .pageIndicatorTopPadding)
                .padding(.bottom, .pageIndicatorBottomPadding)
            }
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
                        Task { await viewModel.reloadHistoryOverview() }
                        return true
                    } : nil,
                    todayDigest: entry.digest
                )
            }
            .toolbar { DismissToolbarItem() }
        }
        .task {
            viewModel.loadCurrentWeek()
            await viewModel.loadHistoryOverview()
        }
        .sheet(isPresented: $isWeekPickerPresented) {
            WeeklySummaryWeekPickerView(
                weeks: viewModel.availableWeeks,
                selectedIndex: $selectedWeekIndex,
                onSelect: selectWeek
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func presentWeekPicker() {
        guard !viewModel.availableWeeks.isEmpty else { return }
        selectedWeekIndex = viewModel.currentWeekIndex
        isWeekPickerPresented = true
    }

    private func selectWeek(at index: Int) {
        withAnimation(.easeInOut(duration: 0.25)) {
            viewModel.currentWeekIndex = index
        }
    }
}

private struct WeekPageView: View {
    let weekInterval: DateInterval
    let score: CompletionScore
    let entries: [WeeklySummaryEntry]

    var body: some View {
        ScrollView {
            VStack(spacing: .rowSpacing) {
                WeeklyPeriodSummaryView(title: weekLabel, score: score)

                ForEach(entries) { entry in
                    NavigationLink(value: entry) {
                        WeeklySummaryRowView(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("weeklySummary.\(entry.digest.weekday.rawValue).button")
                }
            }
            .padding(.horizontal, .screenPadding)
            .padding(.vertical, .screenVerticalPadding)
            .frame(maxWidth: .pageMaximumWidth)
            .frame(maxWidth: .infinity)
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
    static let overallHorizontalPadding = 16.0
    static let overallTopPadding = 12.0
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let rowSpacing = 12.0
    static let pageMaximumWidth = 720.0
    static let pageControlMaximumWidth = 260.0
    static let pageControlHeight = 30.0
    static let pageIndicatorTopPadding = 8.0
    static let pageIndicatorBottomPadding = 10.0
}
