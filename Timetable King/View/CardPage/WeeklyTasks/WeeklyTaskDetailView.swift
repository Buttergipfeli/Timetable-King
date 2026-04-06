import SwiftUI

struct WeeklyTaskDetailView: View {
    let habit: WeekdayHabit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .contentSpacing) {
                detailCard(title: "timetable.weekly.tasks.detail.day", value: habit.weekday.label)
                detailCard(title: "timetable.weekly.tasks.detail.time", value: habit.timeString)
                detailCard(title: "timetable.weekly.tasks.detail.title", value: habit.habit.title)
            }
            .padding(.horizontal, .screenPadding)
            .padding(.vertical, .screenVerticalPadding)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(habit.habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard(title: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: .cardContentSpacing) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding(.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .cardCornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private extension CGFloat {
    static let screenPadding = 16.0
    static let screenVerticalPadding = 20.0
    static let contentSpacing = 16.0
    static let cardPadding = 16.0
    static let cardCornerRadius = 18.0
    static let cardContentSpacing = 8.0
}
