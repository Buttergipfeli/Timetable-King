import SwiftData

class ModelContextInjectable: AnyObject {
    @ObservationIgnored var modelContext: ModelContext?
    
    func injectModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }
    
    func refresh() { }
}
