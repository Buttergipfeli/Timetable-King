import SwiftData

@MainActor
final class ModelContainerService {
    static private(set) var shared: ModelContainerService!
    
    private let container: ModelContainer
    
    var context: ModelContext {
        guard ModelContainerService.shared != nil else { fatalError("\(#file) was not initialized") }
        return container.mainContext
    }
    
    private init(container: ModelContainer) {
        self.container = container
    }
    
    static func initialize(container: ModelContainer) {
        guard ModelContainerService.shared == nil else { return }
        ModelContainerService.shared = ModelContainerService(container: container)
    }
}
