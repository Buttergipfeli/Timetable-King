import SwiftUI
import SwiftData

@main
struct Timetable_KingApp: App {
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
        .modelContainer(container)
    }
}
