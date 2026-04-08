import SwiftUI

struct WeeklySummaryView: View {
    @State private var viewModel = WeeklySummaryViewModel()

    let weekdayDigests: [WeekdayDigest]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .rowSpacing) {
                    ForEach(viewModel.entries) { entry in
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
            .navigationTitle("timetable.weekly.summary.title")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: WeeklySummaryEntry.self) { entry in
                TodayTasksView(
                    title: entry.digest.weekday.label,
                    embedsNavigationStack: false,
                    todayDigest: entry.digest
                )
            }
            .navigationDestination(for: TodayTaskEntry.self) { entry in
                TodayTaskDetailView(entry: entry, showCloseButton: false)
            }
            .toolbar { DismissToolbarItem() }
        }
        .onChange(of: weekdayDigests, initial: true) {
            viewModel.map(weekdayDigests: weekdayDigests)
        }
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let rowSpacing = 12.0
}
