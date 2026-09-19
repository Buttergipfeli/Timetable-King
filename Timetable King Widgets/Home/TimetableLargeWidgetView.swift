import SwiftUI

struct TimetableLargeWidgetView: View {
    let snapshot: TimetableWidgetSnapshot

    var body: some View {
        if snapshot.weeklyTotalCount > 0 {
            weeklyOverview
        } else {
            emptyState
        }
    }

    private var weeklyOverview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This week")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tint)
                        .textCase(.uppercase)
                    Text("Weekly overview")
                        .font(.title3.bold())
                    Text("\(snapshot.weeklyCompletedCount) of \(snapshot.weeklyTotalCount) tasks completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Text(snapshot.weeklyProgress, format: .percent.precision(.fractionLength(0)))
                    .font(.headline)
                    .foregroundStyle(.tint)
                    .monospacedDigit()
            }

            ProgressView(value: snapshot.weeklyProgress)

            VStack(spacing: 0) {
                ForEach(snapshot.week) { day in
                    TimetableWidgetDayProgressRow(day: day)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This week")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.tint)
                .textCase(.uppercase)
            Text("Weekly overview")
                .font(.title3.bold())
            Spacer()
            Image(systemName: "calendar.badge.checkmark")
                .font(.largeTitle)
                .foregroundStyle(.tint)
            Text("No tasks this week")
                .font(.headline)
            Text("Your schedule is clear")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

private struct TimetableWidgetDayProgressRow: View {
    let day: TimetableWidgetDay

    var body: some View {
        HStack(spacing: 9) {
            Text(day.label)
                .font(.caption.weight(.semibold))
                .frame(width: 32, alignment: .leading)
            ProgressView(value: day.progress)
            Text(day.totalCount > 0 ? "\(day.completedCount)/\(day.totalCount)" : "–")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 28, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
    }
}
