import Foundation

extension String {
    var localized: String {
        String(localized: LocalizationValue(self))
    }
}
