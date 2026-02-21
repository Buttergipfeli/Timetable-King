import SwiftData

@MainActor
final class ModelContainerService {
    static private(set) var shared: ModelContainerService!
    
    private let container: ModelContainer
    
    var context: ModelContext {
        if ModelContainerService.shared == nil {
            fatalError("\(#file) was not initialized")
        }
        
        return ModelContainerService.shared.container.mainContext
    }
    
    private init(container: ModelContainer) {
        self.container = container
    }
    
    static func initialize(container: ModelContainer) {
        ModelContainerService.shared = ModelContainerService(container: container)
    }
}
