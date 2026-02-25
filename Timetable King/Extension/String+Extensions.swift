import Foundation

extension String {
    var localized: String {
        String(localized: LocalizationValue(self))
    }

    func localized(_ params: CVarArg...) -> String {
        String(format: localized, locale: Locale.current, arguments: params)
    }
}
