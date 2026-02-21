import SwiftUI
import SwiftData

@main
struct Timetable_KingApp: App {
    let container: ModelContainer
    
    init() {
#if DEBUG
        container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true)
#else
        container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: false)
#endif
        
#if DEBUG
        setUpTestData(into: container.mainContext)
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
