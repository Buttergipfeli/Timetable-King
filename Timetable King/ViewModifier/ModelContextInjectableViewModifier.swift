import SwiftUI

private struct ModelContextInjectableViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    let modelContextInjectable: ModelContextInjectable
    
    func body(content: Content) -> some View {
        content
            .task {
                modelContextInjectable.injectModelContext(modelContext)
            }
    }
}

extension View {
    func injectModelContext(in modelContextInjectable: ModelContextInjectable) -> some View {
        modifier(ModelContextInjectableViewModifier(modelContextInjectable: modelContextInjectable))
    }
}
