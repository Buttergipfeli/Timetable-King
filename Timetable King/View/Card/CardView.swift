import SwiftUI

struct CardView<Content: View>: View {
    @State private var isPresented: Bool = false
    
    let isEmpty: Bool
    let title: LocalizedStringKey
    let content: () -> Content
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            VStack(alignment: .leading) {
                CardTitleView(title: title)
                    .padding([.horizontal, .top], .cardPadding)
                
                ScrollView {
                    VStack(spacing: .entryListSpacing) {
                        if isEmpty {
                            CardEmptyView(errorMessage: "timetable.card.empty")
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
}

private extension CGFloat {
    static let entryListSpacing = 8.0
    static let entriesScrollHeight = 140.0
    static let cardCornerRadius = 20.0
    static let cardPadding = 16.0
}
