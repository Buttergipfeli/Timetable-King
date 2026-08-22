import SwiftUI

struct AppTheme {
    let accent: Color
    let secondaryAccent: Color
    let accentSurface: Color
    let logoPrimary: Color
    let logoSecondary: Color
}

extension AppPalette {
    func theme(for colorScheme: ColorScheme) -> AppTheme {
        let variant = colorScheme == .dark ? dark : light
        return AppTheme(
            accent: variant.accent.color,
            secondaryAccent: variant.secondary.color,
            accentSurface: variant.surface.color,
            logoPrimary: variant.logoPrimary.color,
            logoSecondary: variant.logoSecondary.color
        )
    }
}

private extension HSLColor {
    var color: Color {
        Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}
