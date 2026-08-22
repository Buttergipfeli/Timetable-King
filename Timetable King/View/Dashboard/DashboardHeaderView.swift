import SwiftUI

struct DashboardHeaderView: View {
    @Environment(\.appTheme) private var theme

    let date: Date
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(spacing: .contentSpacing) {
            brandMark

            VStack(alignment: .leading, spacing: .titleSpacing) {
                Text("Timetable King")
                    .font(.headline.weight(.bold))

                Text(date.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onOpenSettings) {
                Image(systemName: "gearshape")
                    .font(.body.weight(.semibold))
                    .frame(width: .settingsButtonSize, height: .settingsButtonSize)
                    .background(.thinMaterial, in: Circle())
            }
            .accessibilityIdentifier("dashboard.settings.button")
            .accessibilityLabel("settings.title")
        }
    }

    private var brandMark: some View {
        Image(systemName: "calendar.badge.checkmark")
            .font(.system(size: .brandIconSize, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: .brandMarkSize, height: .brandMarkSize)
            .background(
                LinearGradient(
                    colors: [theme.logoPrimary, theme.logoSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: .brandCornerRadius)
            )
    }
}

private extension CGFloat {
    static let contentSpacing = 11.0
    static let titleSpacing = 2.0
    static let settingsButtonSize = 40.0
    static let brandMarkSize = 42.0
    static let brandIconSize = 20.0
    static let brandCornerRadius = 13.0
}
