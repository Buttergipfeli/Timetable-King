import SwiftUI
import SwiftData

@main
struct Timetable_KingApp: App {
    @Namespace private var namespace
    
    let container: ModelContainer
    
    init() {
#if DEBUG
        container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true)
        setUpTestData(into: container.mainContext)
#else
        container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: false)
#endif
        
        ModelContainerService.initialize(container: container)
    }
    
    var body: some Scene {
        WindowGroup {
            TimetableKingAppView()
        }
        .environment(\.namespace, namespace)
        .modelContainer(container)
    }
}
