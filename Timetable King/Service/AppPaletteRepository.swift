import Foundation

@MainActor
protocol AppPaletteRepository {
    func load() -> AppPalette?
    func save(_ palette: AppPalette)
}

@MainActor
struct UserDefaultsAppPaletteRepository: AppPaletteRepository {
    private let storage: AppPaletteStorage
    private let legacyStorage: AppPaletteStorage?

    init() {
        storage = AppPaletteStorage()
        legacyStorage = AppPaletteStorage(userDefaults: .standard)
    }

    init(userDefaults: UserDefaults, key: String = "app.palette") {
        storage = AppPaletteStorage(userDefaults: userDefaults, key: key)
        legacyStorage = nil
    }

    func load() -> AppPalette? {
        if let palette = storage.load() {
            return palette
        }

        guard let palette = legacyStorage?.load() else { return nil }
        storage.save(palette)
        return palette
    }

    func save(_ palette: AppPalette) {
        storage.save(palette)
    }
}
