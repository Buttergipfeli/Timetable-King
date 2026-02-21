import SwiftUI
import SwiftData

struct TimetableKingAppView: View {
    @State private var viewModel = TimetableKingAppViewModel(modelContainerService: .shared)
    
    var body: some View {
        ScrollView {
            VStack {
                CardView(entries: viewModel.entries)
            }
            .padding()
        }
    }
}

#Preview {
    TimetableKingAppView()
}
