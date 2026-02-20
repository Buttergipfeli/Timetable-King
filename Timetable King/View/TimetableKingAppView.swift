import SwiftUI

struct TimetableKingAppView: View {
    @State private var viewModel = TimetableKingAppViewModel()
    @State private var isPresented: Bool = false
    
    @Namespace private var cardNamespace
    
    var body: some View {
        ScrollView {
            VStack {
                Button {
                    isPresented = true
                } label: {
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.title2)
                        
                        ScrollView {
                            VStack {
                                RoundedRectangle(cornerRadius: .cardCornerRadius)
                                RoundedRectangle(cornerRadius: .cardCornerRadius)
                                RoundedRectangle(cornerRadius: .cardCornerRadius)
                                RoundedRectangle(cornerRadius: .cardCornerRadius)
                                RoundedRectangle(cornerRadius: .cardCornerRadius)
                                RoundedRectangle(cornerRadius: .cardCornerRadius)
                            }
                        }
                        .frame(height: 70)
                    }
                    .padding()
                    .glassEffect(.clear, in: .rect(cornerRadius: .cardCornerRadius))
                    .background(RoundedRectangle(cornerRadius: .cardCornerRadius).fill(.orange))
                }
//                .glassEffect(.clear.tint(.orange), in: .rect(cornerRadius: .cardCornerRadius))
                .matchedTransitionSource(id: "Card", in: cardNamespace)
                .fullScreenCover(isPresented: $isPresented) {
                    Color.green
                        .overlay {
                            Button {
                                isPresented = false
                            } label: {
                                Text("Transition View")
                            }
                        }
                        .navigationTransition(id: "Card", in: cardNamespace)
                }
            }
            .padding()
        }
    }
}

private extension CGFloat {
    static let cardHeight = 100.0
    static let cardCornerRadius = 20.0
}

#Preview {
    TimetableKingAppView()
}
