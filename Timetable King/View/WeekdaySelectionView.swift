import SwiftUI

struct WeekdaySelectionView: View {
    @Binding var selection: Set<Weekday>

    var body: some View {
        selectionButton(
            title: "timetable.weekly.tasks.add.every.day".localized,
            isSelected: selection.count == Weekday.allCases.count,
            identifier: "weekday.selection.everyDay.button"
        ) {
            selection = selection.count == Weekday.allCases.count
                ? []
                : Set(Weekday.allCases)
        }

        ForEach(Weekday.allCases, id: \.self) { weekday in
            selectionButton(
                title: weekday.label,
                isSelected: selection.contains(weekday),
                identifier: "weekday.selection.\(weekday.rawValue).button"
            ) {
                if selection.contains(weekday) {
                    selection.remove(weekday)
                } else {
                    selection.insert(weekday)
                }
            }
        }
    }

    private func selectionButton(
        title: String,
        isSelected: Bool,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier(identifier)
    }
}
