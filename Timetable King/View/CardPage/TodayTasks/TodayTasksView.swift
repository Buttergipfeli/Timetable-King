import SwiftUI

struct TodayTasksView: View {
    @State private var viewModel = TodayTasksViewModel()
    @State private var selectedEntry: TodayTaskEntry?

    var title: String? = nil
    var embedsNavigationStack: Bool = true
    var allowsStatusEditing: Bool = false
    var onUpdateStatus: ((TodayTaskEntry, HabitState) -> Bool)? = nil
    let todayDigest: WeekdayDigest?

    var body: some View {
        Group {
            if embedsNavigationStack {
                NavigationStack {
                    content
                        .toolbar { DismissToolbarItem() }
                }
            } else {
                content
            }
        }
        .onChange(of: todayDigest, initial: true) {
            viewModel.map(todayDigest: todayDigest)
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: .sectionSpacing) {
                TodayTasksSectionView(
                    title: "timetable.today.tasks.section.finished",
                    entries: viewModel.finishedEntries,
                    emptyTitle: "timetable.today.tasks.empty.finished.title",
                    emptyMessage: "timetable.today.tasks.empty.finished.message",
                    allowsStatusEditing: allowsStatusEditing,
                    onSelectEntry: { selectedEntry = $0 },
                    onSelectStatus: updateStatus
                )

                TodayTasksSectionView(
                    title: "timetable.today.tasks.section.todo",
                    entries: viewModel.todoEntries,
                    emptyTitle: "timetable.today.tasks.empty.todo.title",
                    emptyMessage: "timetable.today.tasks.empty.todo.message",
                    allowsStatusEditing: allowsStatusEditing,
                    onSelectEntry: { selectedEntry = $0 },
                    onSelectStatus: updateStatus
                )

                if viewModel.futureEntries.isEmpty.not {
                    TodayTasksSectionView(
                        title: "timetable.today.tasks.section.future",
                        entries: viewModel.futureEntries,
                        emptyTitle: "timetable.today.tasks.empty.future.title",
                        emptyMessage: "timetable.today.tasks.empty.future.message",
                        allowsStatusEditing: false,
                        onSelectEntry: { selectedEntry = $0 },
                        onSelectStatus: nil
                    )
                }
            }
            .padding(.horizontal, .screenPadding)
            .padding(.vertical, .screenVerticalPadding)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(title ?? String(localized: "timetable.today.tasks.title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedEntry) { entry in
            TodayTaskDetailView(
                showCloseButton: false,
                allowsStatusEditing: allowsStatusEditing,
                entry: entry,
                onUpdateStatus: updateStatus
            )
        }
    }

    private func updateStatus(for entry: TodayTaskEntry, status: HabitState) -> Bool {
        guard onUpdateStatus?(entry, status) == true else { return false }
        viewModel.updateStatus(for: entry, status: status)
        return true
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let sectionSpacing = 20.0
}
