import SwiftUI

struct CardView: View {
    @State private var isPresented: Bool = false
    
    @Namespace private var cardNamespace
    
    let entries: [WeekdayHabitResult]
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            VStack(alignment: .leading) {
                CardTitleView(title: "timetable.card.title")
                    .padding([.horizontal, .top], .cardPadding)
                
                ScrollView {
                    VStack(spacing: .entryListSpacing) {
                        if entries.isEmpty {
                            CardEmptyView(errorMessage: "timetable.card.empty")
                        } else {
                            ForEach(entries) { entry in
                                CardEntryView(entry: entry)
                            }
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
        .matchedTransitionSource(id: .cardTransitionID, in: cardNamespace)
        .fullScreenCover(isPresented: $isPresented) {
            Color.green
                .overlay {
                    Button {
                        isPresented = false
                    } label: {
                        Text("timetable.transition.title")
                    }
                }
                .navigationTransition(id: .cardTransitionID, in: cardNamespace)
        }
    }
}

private extension CGFloat {
    static let entryListSpacing = 8.0
    static let entriesScrollHeight = 140.0
    static let cardCornerRadius = 20.0
    static let cardPadding = 16.0
}

private extension String {
    static let cardTransitionID = "Card"
}
