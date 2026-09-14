import SwiftUI

final class OnboardingStore {
    static let completionKey = "onboarding.completed"

    @AppStorage
    private(set) var hasCompleted: Bool

    init(userDefaults: UserDefaults = .standard) {
        _hasCompleted = AppStorage(
            wrappedValue: false,
            Self.completionKey,
            store: userDefaults
        )
    }

    func shouldPresent(hasExistingTasks: Bool) -> Bool {
        if hasExistingTasks {
            complete()
        }
        return !hasCompleted
    }

    func complete() {
        hasCompleted = true
    }
}
