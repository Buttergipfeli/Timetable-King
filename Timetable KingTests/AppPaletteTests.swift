import Foundation
import Testing
@testable import Timetable_King

@MainActor
struct AppPaletteTests {
    @Test
    func generatedPalettesMeetContrastRequirements() {
        var randomGenerator = SeededRandomNumberGenerator(seed: 42)
        let paletteGenerator = AppPaletteGenerator()

        for _ in 0..<100 {
            let palette = paletteGenerator.generate(using: &randomGenerator)

            #expect(palette.light.accent.rgb.contrastRatio(with: .white) >= 4.5)
            #expect(palette.light.secondary.rgb.contrastRatio(with: .white) >= 4.5)
            #expect(palette.dark.accent.rgb.contrastRatio(with: .darkBackground) >= 4.5)
            #expect(palette.dark.secondary.rgb.contrastRatio(with: .darkBackground) >= 4.5)
            #expect(palette.light.accent.rgb.contrastRatio(with: palette.light.surface.rgb) >= 4.5)
            #expect(palette.light.secondary.rgb.contrastRatio(with: palette.light.surface.rgb) >= 4.5)
            #expect(palette.dark.accent.rgb.contrastRatio(with: palette.dark.surface.rgb) >= 4.5)
            #expect(palette.dark.secondary.rgb.contrastRatio(with: palette.dark.surface.rgb) >= 4.5)
            #expect(palette.light.logoPrimary.rgb.contrastRatio(with: .white) >= 4.5)
            #expect(palette.light.logoSecondary.rgb.contrastRatio(with: .white) >= 4.5)
            #expect(palette.dark.logoPrimary.rgb.contrastRatio(with: .white) >= 4.5)
            #expect(palette.dark.logoSecondary.rgb.contrastRatio(with: .white) >= 4.5)
        }
    }

    @Test
    func repositoryPersistsPalette() throws {
        let suiteName = "AppPaletteTests.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        let repository = UserDefaultsAppPaletteRepository(userDefaults: userDefaults)
        var randomGenerator = SeededRandomNumberGenerator(seed: 7)
        let palette = AppPaletteGenerator().generate(using: &randomGenerator)

        repository.save(palette)

        #expect(repository.load() == palette)
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
