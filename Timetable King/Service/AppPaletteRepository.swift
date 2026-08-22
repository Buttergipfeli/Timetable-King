import Foundation

@MainActor
protocol AppPaletteRepository {
    func load() -> AppPalette?
    func save(_ palette: AppPalette)
}

@MainActor
struct UserDefaultsAppPaletteRepository: AppPaletteRepository {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "app.palette") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func load() -> AppPalette? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(AppPalette.self, from: data)
    }

    func save(_ palette: AppPalette) {
        guard let data = try? JSONEncoder().encode(palette) else { return }
        userDefaults.set(data, forKey: key)
    }
}
