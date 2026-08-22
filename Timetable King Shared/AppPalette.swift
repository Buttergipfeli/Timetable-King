struct AppPalette: Codable, Equatable, Sendable {
    let id: String
    let light: AppPaletteVariant
    let dark: AppPaletteVariant
}

struct AppPaletteVariant: Codable, Equatable, Sendable {
    let accent: HSLColor
    let secondary: HSLColor
    let surface: HSLColor
    let logoPrimary: HSLColor
    let logoSecondary: HSLColor
}

extension AppPalette {
    static let fallback = AppPalette(
        id: "TK01",
        light: AppPaletteVariant(
            accent: HSLColor(hue: 25, saturation: 68, lightness: 36),
            secondary: HSLColor(hue: 216, saturation: 34, lightness: 36),
            surface: HSLColor(hue: 25, saturation: 24, lightness: 95),
            logoPrimary: HSLColor(hue: 25, saturation: 70, lightness: 30),
            logoSecondary: HSLColor(hue: 216, saturation: 42, lightness: 30)
        ),
        dark: AppPaletteVariant(
            accent: HSLColor(hue: 25, saturation: 72, lightness: 68),
            secondary: HSLColor(hue: 216, saturation: 44, lightness: 72),
            surface: HSLColor(hue: 25, saturation: 18, lightness: 18),
            logoPrimary: HSLColor(hue: 25, saturation: 70, lightness: 30),
            logoSecondary: HSLColor(hue: 216, saturation: 42, lightness: 30)
        )
    )
}
