import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @Environment(\.modelContext) private var modelContext
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
                        Text("timetable.card.title")
                            .font(.title2)
                        
                        ScrollView {
                            VStack(spacing: .entryListSpacing) {
                                if viewModel.entries.isEmpty {
                                    Text("timetable.card.empty")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    ForEach(viewModel.entries) { entry in
                                        HStack(spacing: .entryRowSpacing) {
                                            VStack(alignment: .leading, spacing: .entryTextSpacing) {
                                                Text(entry.habit.title)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(.primary)
                                                Text(entry.weekday.shortLabel)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }

                                            Spacer(minLength: .entryRowSpacerMinLength)

                                            Text(entry.timeString)
                                                .font(.caption.monospacedDigit())
                                                .foregroundStyle(.primary)
                                                .padding(.horizontal, .entryTimeHorizontalPadding)
                                                .padding(.vertical, .entryTimeVerticalPadding)
                                                .background(.thinMaterial, in: Capsule())
                                        }
                                        .padding(.horizontal, .entryHorizontalPadding)
                                        .padding(.vertical, .entryVerticalPadding)
                                        .background(
                                            .white.opacity(.entryBackgroundOpacity),
                                            in: RoundedRectangle(cornerRadius: .entryCornerRadius)
                                        )
                                    }
                                }
                            }
                        }
                        .frame(height: .entriesScrollHeight)
                    }
                    .padding()
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
            .padding()
        }
        .task {
            viewModel.injectModelContext(modelContext)
        }
    }
}

private extension CGFloat {
    static let entryListSpacing = 8.0
    static let entryRowSpacing = 12.0
    static let entryTextSpacing = 2.0
    static let entryRowSpacerMinLength = 8.0
    static let entryTimeHorizontalPadding = 8.0
    static let entryTimeVerticalPadding = 4.0
    static let entryHorizontalPadding = 10.0
    static let entryVerticalPadding = 8.0
    static let entryCornerRadius = 12.0
    static let entriesScrollHeight = 140.0
    static let cardCornerRadius = 20.0
}

private extension Double {
    static let entryBackgroundOpacity = 0.15
}

private extension String {
    static let cardTransitionID = "Card"
}

#Preview {
    TimetableKingAppView()
}
