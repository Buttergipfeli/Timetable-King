import SwiftUI

struct TodayTasksView: View {
    @State private var viewModel = TodayTasksViewModel()

    let todayDigest: WeekdayDigest?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .sectionSpacing) {
                    TodayTasksSectionView(
                        title: "timetable.today.tasks.section.finished",
                        entries: viewModel.finishedEntries,
                        emptyTitle: "timetable.today.tasks.empty.finished.title",
                        emptyMessage: "timetable.today.tasks.empty.finished.message"
                    )

                    TodayTasksSectionView(
                        title: "timetable.today.tasks.section.todo",
                        entries: viewModel.todoEntries,
                        emptyTitle: "timetable.today.tasks.empty.todo.title",
                        emptyMessage: "timetable.today.tasks.empty.todo.message"
                    )
                }
                .padding(.horizontal, .screenPadding)
                .padding(.vertical, .screenVerticalPadding)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("timetable.today.tasks.title")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TodayTaskEntry.self) { entry in
                TodayTaskDetailView(entry: entry, showCloseButton: false)
            }
            .toolbar { DismissToolbarItem() }
        }
        .onChange(of: todayDigest, initial: true) {
            viewModel.map(todayDigest: todayDigest)
        }
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let sectionSpacing = 20.0
}
