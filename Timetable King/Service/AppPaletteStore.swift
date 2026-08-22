import Observation

@MainActor
@Observable
final class AppPaletteStore {
    private(set) var palette: AppPalette

    private let repository: any AppPaletteRepository
    private let generator: AppPaletteGenerator

    init(
        repository: (any AppPaletteRepository)? = nil,
        generator: AppPaletteGenerator? = nil
    ) {
        let repository = repository ?? UserDefaultsAppPaletteRepository()
        let generator = generator ?? AppPaletteGenerator()

        if let savedPalette = repository.load() {
            palette = savedPalette
        } else {
            let generatedPalette = generator.generate()
            palette = generatedPalette
            repository.save(generatedPalette)
        }

        self.repository = repository
        self.generator = generator
    }

    func generatePalette() {
        var generatedPalette = generator.generate()
        while generatedPalette.id == palette.id {
            generatedPalette = generator.generate()
        }
        palette = generatedPalette
        repository.save(generatedPalette)
    }
}
