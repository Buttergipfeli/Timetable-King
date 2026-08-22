import SwiftUI

struct DashboardAddTaskButton: View {
    @Environment(\.appTheme) private var theme

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: .contentSpacing) {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: .iconSize, height: .iconSize)
                    .background(theme.logoPrimary, in: Circle())

                Text("dashboard.add.task")
                    .font(.headline.weight(.semibold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, .horizontalPadding)
            .padding(.vertical, .verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(.primary.opacity(.borderOpacity), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private extension CGFloat {
    static let contentSpacing = 12.0
    static let iconSize = 34.0
    static let horizontalPadding = 16.0
    static let verticalPadding = 13.0
    static let cornerRadius = 18.0
}

private extension Double {
    static let borderOpacity = 0.06
}
