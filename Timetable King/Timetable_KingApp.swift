import SwiftUI
import SwiftData

@main
struct Timetable_KingApp: App {
    @Namespace private var namespace
    @State private var paletteStore = AppPaletteStore()
    
    let container: ModelContainer
    
    init() {
#if DEBUG
        container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: true)
        Timetable_KingApp.setUpTestData(into: container.mainContext)
        try? container.mainContext.save()
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
        .environment(paletteStore)
        .modelContainer(container)
    }
}
