import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @State private var viewModel = TimetableKingAppViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                CardView(entries: viewModel.entries)
            }
            .padding()
        }
        .injectModelContext(in: viewModel)
    }
}

#Preview {
    TimetableKingAppView()
}
