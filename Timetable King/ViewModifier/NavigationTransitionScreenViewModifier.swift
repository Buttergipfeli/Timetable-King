import SwiftUI

private struct NavigationZoomTransitionViewModifier: ViewModifier {
    let transitionID: String
    let namespace: Namespace.ID?
    
    func body(content: Content) -> some View {
        if let namespace {
            content
                .navigationTransition(.zoom(sourceID: transitionID, in: namespace))
        } else {
            content
        }
    }
}

private struct MatchedTransitionSourceViewModifier: ViewModifier {
    let transitionID: String
    let namespace: Namespace.ID?
    
    func body(content: Content) -> some View {
        if let namespace {
            content
                .matchedTransitionSource(id: transitionID, in: namespace)
        } else {
            content
        }
    }
}

extension View {
    func navigationTransition(id: String, in namespace: Namespace.ID?) -> some View {
        modifier(NavigationZoomTransitionViewModifier(transitionID: id, namespace: namespace))
    }
    
    func matchedTransitionSource(id: String, in namespace: Namespace.ID?) -> some View {
        modifier(MatchedTransitionSourceViewModifier(transitionID: id, namespace: namespace))
    }
}
