import Foundation

final class OnboardingStore {
    static let completionKey = "onboarding.completed"

    private let userDefaults: UserDefaults

    var hasCompleted: Bool {
        userDefaults.bool(forKey: Self.completionKey)
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func shouldPresent(hasExistingTasks: Bool) -> Bool {
        if hasExistingTasks {
            complete()
        }
        return !hasCompleted
    }

    func complete() {
        userDefaults.set(true, forKey: Self.completionKey)
    }
}
