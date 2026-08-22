import SwiftUI

struct WeeklySummaryWeekPickerView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let weeks: [DateInterval]
    @Binding var selectedIndex: Int
    let onSelect: (Int) -> Void

    var body: some View {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return NavigationStack {
            VStack(spacing: .sectionSpacing) {
                Text("weekly.summary.jump.description")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                GlassEffectContainer(spacing: .shortcutSpacing) {
                    HStack(spacing: .shortcutSpacing) {
                        shortcutButton(
                            title: String(localized: "weekly.summary.jump.current"),
                            systemImage: "calendar.badge.clock",
                            index: weeks.indices.last
                        )

                        shortcutButton(
                            title: String(localized: "weekly.summary.jump.oldest"),
                            systemImage: "backward.end.fill",
                            index: weeks.indices.first
                        )
                    }
                }

                Picker("weekly.summary.jump.choose", selection: $selectedIndex) {
                    ForEach(weeks.indices, id: \.self) { index in
                        Text(weekLabel(at: index, formatter: formatter))
                            .tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: .pickerHeight)
                .clipped()

                Button {
                    select(index: selectedIndex)
                } label: {
                    Text("weekly.summary.jump.show")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .tint(theme.accent)
                .controlSize(.large)
                .disabled(!weeks.indices.contains(selectedIndex))
            }
            .padding(.horizontal, .horizontalPadding)
            .padding(.bottom, .bottomPadding)
            .navigationTitle(String(localized: "weekly.summary.jump.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                DismissToolbarItem()
            }
        }
    }

    private func shortcutButton(title: String, systemImage: String, index: Int?) -> some View {
        Button {
            guard let index else { return }
            select(index: index)
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: .shortcutHeight)
        }
        .buttonStyle(.glass(.regular.tint(theme.accent.opacity(0.22)).interactive()))
        .buttonBorderShape(.capsule)
        .tint(theme.accent)
        .overlay {
            Capsule()
                .stroke(theme.accent.opacity(0.38), lineWidth: 1)
        }
        .disabled(index == nil)
    }

    private func weekLabel(at index: Int, formatter: DateIntervalFormatter) -> String {
        if index == weeks.indices.last {
            return String(localized: "weekly.summary.current.week")
        }

        if let lastWeekIndex = weeks.indices.last,
           index == lastWeekIndex - 1 {
            return String(localized: "weekly.summary.last.week")
        }

        let week = weeks[index]
        return formatter.string(from: week.start, to: week.end - 1)
    }

    private func select(index: Int) {
        guard weeks.indices.contains(index) else { return }
        selectedIndex = index
        onSelect(index)
        dismiss()
    }
}

private extension CGFloat {
    static let sectionSpacing = 14.0
    static let shortcutSpacing = 12.0
    static let shortcutHeight = 44.0
    static let pickerHeight = 150.0
    static let horizontalPadding = 20.0
    static let bottomPadding = 16.0
}
