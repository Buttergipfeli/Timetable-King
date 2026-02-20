import SwiftData

@MainActor
protocol ModelContextInjectable: AnyObject {
    func injectModelContext(_ modelContext: ModelContext)
}
