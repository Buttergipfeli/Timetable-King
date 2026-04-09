import SwiftUI

struct TodayTaskReviewView: View {
    @State private var viewModel = TodayTaskReviewViewModel()
    @State private var cardOffset: CGFloat = 0
    @State private var feedbackEmoji: String?
    @State private var feedbackScale: CGFloat = 0.4
    @State private var feedbackOpacity = 0.0
    @State private var isProcessingAction = false

    let session: TodayTaskReviewSession
    let onResolve: (TodayTaskReviewEntry, HabitState) -> Void
    let onFinish: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background
                    .ignoresSafeArea()

                VStack(spacing: .screenSpacing) {
                    header

                    Spacer()

                    if let entry = viewModel.currentEntry {
                        card(entry: entry, width: geometry.size.width - (.screenPadding * 2))
                    }

                    actionBar
                }
                .padding(.horizontal, .screenPadding)
                .padding(.top, geometry.safeAreaInsets.top + .screenTopPadding)
                .padding(.bottom, max(geometry.safeAreaInsets.bottom, .minimumBottomInset) + .screenBottomPadding)

                if let feedbackEmoji {
                    Text(feedbackEmoji)
                        .font(.system(size: .feedbackEmojiSize))
                        .scaleEffect(feedbackScale)
                        .opacity(feedbackOpacity)
                }
            }
            .interactiveDismissDisabled()
            .onChange(of: session, initial: true) {
                viewModel.map(session: session)
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.orange.opacity(0.95),
                Color.yellow.opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Circle()
                .fill(.white.opacity(.backgroundShapeOpacity))
                .frame(width: .backgroundShapeSize, height: .backgroundShapeSize)
                .offset(x: .backgroundShapeXOffset, y: .backgroundShapeYOffset)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: .headerSpacing) {
            Text("timetable.today.review.title")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)

            Text("timetable.today.review.message")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(.headerSecondaryOpacity))
                .multilineTextAlignment(.leading)

            if viewModel.totalCount > 0 {
                Text("timetable.today.review.progress".localized(viewModel.currentStep, viewModel.totalCount))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, .progressHorizontalPadding)
                    .padding(.vertical, .progressVerticalPadding)
                    .background(.white.opacity(.progressBackgroundOpacity), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionBar: some View {
        VStack(spacing: .actionSpacing) {
            HStack(spacing: .buttonSpacing) {
                actionButton(
                    systemImage: "xmark",
                    tint: .red,
                    action: { process(.failed) }
                )

                actionButton(
                    systemImage: "checkmark",
                    tint: .green,
                    action: { process(.done) }
                )
            }

            Button("timetable.today.review.later") {
                process(.later)
            }
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, .laterHorizontalPadding)
            .padding(.vertical, .laterVerticalPadding)
            .background(.white.opacity(.laterBackgroundOpacity), in: Capsule())
            .disabled(isProcessingAction)
        }
    }

    private func card(entry: TodayTaskReviewEntry, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: .cardContentSpacing) {
            Text(entry.timeString)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .padding(.horizontal, .timeHorizontalPadding)
                .padding(.vertical, .timeVerticalPadding)
                .background(Color.orange.opacity(.timeBackgroundOpacity), in: Capsule())

            Text(entry.title)
                .font(.system(size: .titleFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(.titleLineLimit)
                .multilineTextAlignment(.leading)

            Text("timetable.today.review.question")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.cardPadding)
        .frame(maxWidth: .infinity, minHeight: .cardMinHeight, alignment: .leading)
        .background(cardBackground)
        .overlay(alignment: .topLeading) {
            swipeIndicator(
                title: "timetable.today.review.done",
                systemImage: "checkmark.circle.fill",
                tint: .green,
                opacity: positiveSwipeOpacity
            )
        }
        .overlay(alignment: .topTrailing) {
            swipeIndicator(
                title: "timetable.today.review.failed",
                systemImage: "xmark.circle.fill",
                tint: .red,
                opacity: negativeSwipeOpacity
            )
        }
        .frame(width: width)
        .offset(x: cardOffset)
        .rotationEffect(.degrees(cardOffset / .rotationDivisor))
        .gesture(dragGesture)
        .animation(.spring(duration: .cardAnimationDuration, bounce: .cardAnimationBounce), value: cardOffset)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: .cardCornerRadius)
            .fill(Color(.systemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: .cardCornerRadius)
                    .fill(swipeOverlayColor.opacity(swipeOverlayOpacity))
            }
    }

    private func swipeIndicator(
        title: LocalizedStringKey,
        systemImage: String,
        tint: Color,
        opacity: Double
    ) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, .indicatorHorizontalPadding)
            .padding(.vertical, .indicatorVerticalPadding)
            .background(Color(.systemBackground), in: Capsule())
            .padding(.indicatorPadding)
            .opacity(opacity)
    }

    private func actionButton(systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: .actionIconSize, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: .actionButtonSize, height: .actionButtonSize)
                .background(tint, in: Circle())
        }
        .disabled(isProcessingAction)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard isProcessingAction.not else { return }
                cardOffset = value.translation.width
            }
            .onEnded { value in
                guard isProcessingAction.not else { return }

                if value.translation.width >= .swipeThreshold {
                    process(.done)
                } else if value.translation.width <= -.swipeThreshold {
                    process(.failed)
                } else {
                    withAnimation(.spring(duration: .resetAnimationDuration, bounce: .resetAnimationBounce)) {
                        cardOffset = 0
                    }
                }
            }
    }

    private var positiveSwipeOpacity: Double {
        max(0, min(1, cardOffset / .swipeThreshold))
    }

    private var negativeSwipeOpacity: Double {
        max(0, min(1, -cardOffset / .swipeThreshold))
    }

    private var swipeOverlayColor: Color {
        if cardOffset > 0 { return .green }
        if cardOffset < 0 { return .red }
        return .clear
    }

    private var swipeOverlayOpacity: Double {
        max(0, min(.maximumOverlayOpacity, abs(cardOffset) / .maximumOverlayDistance))
    }

    private func process(_ action: TodayTaskReviewAction) {
        guard let entry = viewModel.currentEntry, isProcessingAction.not else { return }

        isProcessingAction = true

        if let status = action.status {
            onResolve(entry, status)
        }

        if action.swipeDirection != 0 {
            withAnimation(.spring(duration: .swipeAnimationDuration, bounce: .swipeAnimationBounce)) {
                cardOffset = action.swipeDirection * .programmaticSwipeDistance
            }
        }

        showFeedback(action.feedbackEmoji)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(.advanceDelay))

            cardOffset = 0
            viewModel.advance()
            isProcessingAction = false

            if viewModel.currentEntry == nil {
                onFinish()
            }
        }
    }

    private func showFeedback(_ emoji: String) {
        feedbackEmoji = emoji
        feedbackScale = .feedbackStartScale
        feedbackOpacity = 0

        withAnimation(.spring(duration: .feedbackAnimationDuration, bounce: .feedbackAnimationBounce)) {
            feedbackScale = .feedbackEndScale
            feedbackOpacity = 1
        }

        withAnimation(.easeOut(duration: .feedbackFadeDuration).delay(.feedbackVisibleDelay)) {
            feedbackOpacity = 0
        }
    }
}

private enum TodayTaskReviewAction {
    case done
    case failed
    case later

    var feedbackEmoji: String {
        emojis.randomElement() ?? "🙂"
    }

    private var emojis: [String] {
        switch self {
        case .done:
            ["🥳", "😄", "🤩", "😁", "😊", "😎", "🙂", "🤓", "🫡"]
        case .failed:
            ["😴", "🥱", "😪", "💤", "🛌", "😮‍💨", "😡", "😖", "🙄"]
        case .later:
            ["🤷", "🤔", "😅", "🤨"]
        }
    }

    var status: HabitState? {
        switch self {
        case .done:
            .done
        case .failed:
            .failed
        case .later:
            nil
        }
    }

    var swipeDirection: CGFloat {
        switch self {
        case .done:
            1
        case .failed:
            -1
        case .later:
            0
        }
    }
}

private extension CGFloat {
    static let screenPadding = 20.0
    static let screenTopPadding = 20.0
    static let screenBottomPadding = 24.0
    static let screenSpacing = 24.0
    static let headerSpacing = 12.0
    static let progressHorizontalPadding = 10.0
    static let progressVerticalPadding = 6.0
    static let backgroundShapeSize = 240.0
    static let backgroundShapeXOffset = 140.0
    static let backgroundShapeYOffset = -220.0
    static let cardPadding = 24.0
    static let cardMinHeight = 320.0
    static let cardCornerRadius = 28.0
    static let cardContentSpacing = 18.0
    static let timeHorizontalPadding = 10.0
    static let timeVerticalPadding = 6.0
    static let titleFontSize = 30.0
    static let buttonSpacing = 28.0
    static let actionSpacing = 18.0
    static let actionButtonSize = 72.0
    static let actionIconSize = 26.0
    static let laterHorizontalPadding = 18.0
    static let laterVerticalPadding = 12.0
    static let indicatorHorizontalPadding = 10.0
    static let indicatorVerticalPadding = 7.0
    static let indicatorPadding = 18.0
    static let swipeThreshold = 110.0
    static let maximumOverlayDistance = 180.0
    static let maximumOverlayOpacity = 0.2
    static let programmaticSwipeDistance = 420.0
    static let rotationDivisor = 24.0
    static let feedbackEmojiSize = 88.0
    static let feedbackStartScale = 0.45
    static let feedbackEndScale = 1.15
    static let minimumBottomInset = 16.0
}

private extension Double {
    static let cardAnimationDuration = 0.32
    static let cardAnimationBounce = 0.16
    static let resetAnimationDuration = 0.28
    static let resetAnimationBounce = 0.22
    static let swipeAnimationDuration = 0.34
    static let swipeAnimationBounce = 0.06
    static let feedbackAnimationDuration = 0.36
    static let feedbackAnimationBounce = 0.42
    static let feedbackFadeDuration = 0.22
    static let feedbackVisibleDelay = 0.38
    static let advanceDelay = 0.46
    static let headerSecondaryOpacity = 0.88
    static let progressBackgroundOpacity = 0.18
    static let laterBackgroundOpacity = 0.18
    static let timeBackgroundOpacity = 0.14
    static let backgroundShapeOpacity = 0.18
}

private extension Int {
    static let titleLineLimit = 3
}
