import SwiftUI
import SwiftData

@main
struct Timetable_KingApp: App {
    @Namespace private var namespace
    @State private var paletteStore = AppPaletteStore()
    
    let container: ModelContainer
    
    init() {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        let usesDemoData = arguments.contains("--demo-data")
        let usesEmptyStore = arguments.contains("--empty-store")
        container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: usesDemoData || usesEmptyStore)
        if usesDemoData {
            Timetable_KingApp.setUpTestData(into: container.mainContext)
            try? container.mainContext.save()
        }
        if arguments.contains("--reset-onboarding") {
            UserDefaults.standard.removeObject(forKey: OnboardingStore.completionKey)
        }
#else
        container = Timetable_KingApp.setUpModelContainer(isStoredInMemoryOnly: false)
#endif
        
        ModelContainerService.initialize(container: container)
        _ = TaskReminderService.shared
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
