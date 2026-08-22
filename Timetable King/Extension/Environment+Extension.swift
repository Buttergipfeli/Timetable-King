import SwiftUI

extension EnvironmentValues {
    @Entry var namespace: Namespace.ID?
    @Entry var appTheme = AppPalette.fallback.theme(for: .light)
}
