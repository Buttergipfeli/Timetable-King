import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TimetableKingAppViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                CardView(entries: viewModel.entries)
            }
            .padding()
        }
        .task {
            viewModel.injectModelContext(modelContext)
        }
    }
}

#Preview {
    TimetableKingAppView()
}
