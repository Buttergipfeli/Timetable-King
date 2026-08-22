import Foundation

struct RGBColorComponents: Codable, Equatable, Sendable {
    let red: Double
    let green: Double
    let blue: Double

    static let white = RGBColorComponents(red: 1, green: 1, blue: 1)
    static let darkBackground = RGBColorComponents(red: 29 / 255, green: 31 / 255, blue: 34 / 255)

    var relativeLuminance: Double {
        let channels = [red, green, blue].map { channel in
            channel <= 0.03928
                ? channel / 12.92
                : pow((channel + 0.055) / 1.055, 2.4)
        }

        return channels[0] * 0.2126 + channels[1] * 0.7152 + channels[2] * 0.0722
    }

    func contrastRatio(with other: RGBColorComponents) -> Double {
        let brighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)
        return (brighter + 0.05) / (darker + 0.05)
    }
}

struct HSLColor: Codable, Equatable, Sendable {
    let hue: Double
    let saturation: Double
    let lightness: Double

    var rgb: RGBColorComponents {
        let normalizedSaturation = saturation / 100
        let normalizedLightness = lightness / 100
        let chroma = (1 - abs(2 * normalizedLightness - 1)) * normalizedSaturation
        let section = normalizedHue / 60
        let secondary = chroma * (1 - abs(section.truncatingRemainder(dividingBy: 2) - 1))

        let channels: (Double, Double, Double) = switch section {
        case 0..<1: (chroma, secondary, 0)
        case 1..<2: (secondary, chroma, 0)
        case 2..<3: (0, chroma, secondary)
        case 3..<4: (0, secondary, chroma)
        case 4..<5: (secondary, 0, chroma)
        default: (chroma, 0, secondary)
        }

        let match = normalizedLightness - chroma / 2
        return RGBColorComponents(
            red: channels.0 + match,
            green: channels.1 + match,
            blue: channels.2 + match
        )
    }

    private var normalizedHue: Double {
        let value = hue.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
}
