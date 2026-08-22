import SwiftUI
import UIKit

struct WeeklySummaryPageControl: UIViewRepresentable {
    @Environment(\.appTheme) private var theme

    let pageCount: Int
    @Binding var currentPage: Int
    let onLongPress: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.allowsContinuousInteraction = true
        pageControl.backgroundStyle = .minimal
        pageControl.backgroundColor = .clear
        pageControl.isOpaque = false
        pageControl.accessibilityIdentifier = "weeklySummary.pageControl"
        pageControl.accessibilityHint = String(localized: "weekly.summary.jump.hint")
        pageControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.pageChanged(_:)),
            for: .valueChanged
        )
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.pageControlLongPressed(_:))
        )
        longPressGesture.minimumPressDuration = 0.6
        longPressGesture.cancelsTouchesInView = false
        longPressGesture.delegate = context.coordinator
        pageControl.addGestureRecognizer(longPressGesture)
        return pageControl
    }

    func updateUIView(_ pageControl: UIPageControl, context: Context) {
        context.coordinator.parent = self
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = min(max(currentPage, 0), max(pageCount - 1, 0))
        pageControl.currentPageIndicatorTintColor = UIColor(theme.accent)
        pageControl.pageIndicatorTintColor = UIColor.secondaryLabel.withAlphaComponent(0.45)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: WeeklySummaryPageControl

        init(parent: WeeklySummaryPageControl) {
            self.parent = parent
        }

        @objc func pageChanged(_ sender: UIPageControl) {
            withAnimation(.easeInOut(duration: 0.25)) {
                parent.currentPage = sender.currentPage
            }
        }

        @objc func pageControlLongPressed(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            parent.onLongPress()
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}
