import SwiftUI

struct CardView<Content: View>: View {
    let isEmpty: Bool
    let title: LocalizedStringKey
    let action: () -> Void
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: action) {
                CardTitleView(title: title)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding([.horizontal, .top], .cardPadding)

            ScrollView {
                VStack(spacing: .entryListSpacing) {
                    if isEmpty {
                        Button(action: action) {
                            CardEmptyView(errorMessage: "timetable.card.empty")
                        }
                        .buttonStyle(.plain)
                    } else {
                        content()
                    }
                }
                .padding([.horizontal], .cardPadding)
            }
            .contentMargins(.bottom, .cardPadding)
            .frame(height: .entriesScrollHeight)
        }
        .glassEffect(.clear, in: .rect(cornerRadius: .cardCornerRadius))
        .background(RoundedRectangle(cornerRadius: .cardCornerRadius).fill(.orange))
    }
}

private extension CGFloat {
    static let entryListSpacing = 8.0
    static let entriesScrollHeight = 140.0
    static let cardCornerRadius = 20.0
    static let cardPadding = 16.0
}
