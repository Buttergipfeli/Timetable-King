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
                        Text("Timetable")
                            .font(.title2)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                if viewModel.entries.isEmpty {
                                    Text("Keine Einträge vorhanden")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    ForEach(viewModel.entries) { entry in
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(entry.title)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(.primary)
                                                Text(entry.weekdayLabel)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }

                                            Spacer(minLength: 8)

                                            Text(entry.time)
                                                .font(.caption.monospacedDigit())
                                                .foregroundStyle(.primary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(.thinMaterial, in: Capsule())
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        .frame(height: 140)
                    }
                    .padding()
                    .glassEffect(.clear, in: .rect(cornerRadius: .cardCornerRadius))
                    .background(RoundedRectangle(cornerRadius: .cardCornerRadius).fill(.orange))
                }
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
        .task {
            viewModel.injectModelContext(modelContext)
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
