import Foundation

struct AppPaletteStorage {
    private let userDefaults: UserDefaults
    private let key: String

    init(
        userDefaults: UserDefaults = TimetableKingAppGroup.userDefaults,
        key: String = "app.palette"
    ) {
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
