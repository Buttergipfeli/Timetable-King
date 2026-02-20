import SwiftUI
import SwiftData

@main
struct Timetable_KingApp: App {
    let container: ModelContainer
    
    init() {
        container = Timetable_KingApp.setUpModelContainer()
        
        #if DEBUG
        setUpTestData(into: container.mainContext)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            TimetableKingAppView()
        }
        .modelContainer(container)
    }
}
