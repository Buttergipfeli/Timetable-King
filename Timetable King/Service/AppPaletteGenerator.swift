import Foundation

struct AppPaletteGenerator {
    func generate() -> AppPalette {
        var generator = SystemRandomNumberGenerator()
        return generate(using: &generator)
    }

    func generate<Generator: RandomNumberGenerator>(using generator: inout Generator) -> AppPalette {
        let hue = Double(Int.random(in: 0...359, using: &generator))
        let secondaryHue = (hue + Double(Int.random(in: 73...167, using: &generator)))
            .truncatingRemainder(dividingBy: 360)
        let saturation = Double(Int.random(in: 48...68, using: &generator))
        let secondarySaturation = Double(Int.random(in: 36...58, using: &generator))
        let darkAccentSaturation = min(74, saturation + 4)
        let darkSecondarySaturation = min(70, secondarySaturation + 5)
        let logoPrimarySaturation = min(72, saturation + 5)
        let logoSecondarySaturation = min(68, secondarySaturation + 7)
        let lightSurface = HSLColor(
            hue: hue,
            saturation: saturation * 0.35,
            lightness: 95
        )
        let darkSurface = HSLColor(
            hue: hue,
            saturation: saturation * 0.3,
            lightness: 18
        )

        let lightAccent = accessibleLightness(
            hue: hue,
            saturation: saturation,
            initialLightness: 43,
            backgrounds: [.white, lightSurface.rgb],
            step: -1
        )
        let lightSecondary = accessibleLightness(
            hue: secondaryHue,
            saturation: secondarySaturation,
            initialLightness: 42,
            backgrounds: [.white, lightSurface.rgb],
            step: -1
        )
        let darkAccent = accessibleLightness(
            hue: hue,
            saturation: darkAccentSaturation,
            initialLightness: 63,
            backgrounds: [.darkBackground, darkSurface.rgb],
            step: 1
        )
        let darkSecondary = accessibleLightness(
            hue: secondaryHue,
            saturation: darkSecondarySaturation,
            initialLightness: 64,
            backgrounds: [.darkBackground, darkSurface.rgb],
            step: 1
        )
        let logoPrimaryLightness = accessibleLightness(
            hue: hue,
            saturation: logoPrimarySaturation,
            initialLightness: 34,
            backgrounds: [.white],
            step: -1
        )
        let logoSecondaryLightness = accessibleLightness(
            hue: secondaryHue,
            saturation: logoSecondarySaturation,
            initialLightness: 34,
            backgrounds: [.white],
            step: -1
        )

        let identifier = String(format: "%04X", Int.random(in: 0...0xFFFF, using: &generator))

        return AppPalette(
            id: identifier,
            light: AppPaletteVariant(
                accent: HSLColor(hue: hue, saturation: saturation, lightness: lightAccent),
                secondary: HSLColor(hue: secondaryHue, saturation: secondarySaturation, lightness: lightSecondary),
                surface: lightSurface,
                logoPrimary: HSLColor(hue: hue, saturation: logoPrimarySaturation, lightness: logoPrimaryLightness),
                logoSecondary: HSLColor(hue: secondaryHue, saturation: logoSecondarySaturation, lightness: logoSecondaryLightness)
            ),
            dark: AppPaletteVariant(
                accent: HSLColor(hue: hue, saturation: darkAccentSaturation, lightness: darkAccent),
                secondary: HSLColor(hue: secondaryHue, saturation: darkSecondarySaturation, lightness: darkSecondary),
                surface: darkSurface,
                logoPrimary: HSLColor(hue: hue, saturation: logoPrimarySaturation, lightness: logoPrimaryLightness),
                logoSecondary: HSLColor(hue: secondaryHue, saturation: logoSecondarySaturation, lightness: logoSecondaryLightness)
            )
        )
    }

    private func accessibleLightness(
        hue: Double,
        saturation: Double,
        initialLightness: Double,
        backgrounds: [RGBColorComponents],
        step: Double
    ) -> Double {
        var lightness = initialLightness

        while backgrounds.contains(where: {
            HSLColor(hue: hue, saturation: saturation, lightness: lightness)
                .rgb
                .contrastRatio(with: $0) < 4.5
        }),
              lightness > 16,
              lightness < 84 {
            lightness += step
        }

        return lightness
    }
}
