import SwiftUI

struct CardEntryView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(spacing: .entryRowSpacing) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .entryHorizontalPadding)
        .padding(.vertical, .entryVerticalPadding)
        .background(
            .white.opacity(.entryBackgroundOpacity),
            in: RoundedRectangle(cornerRadius: .entryCornerRadius)
        )
    }
}

private extension CGFloat {
    static let entryRowSpacing = 12.0
    static let entryHorizontalPadding = 10.0
    static let entryVerticalPadding = 8.0
    static let entryCornerRadius = 12.0
}

private extension Double {
    static let entryBackgroundOpacity = 0.15
}
