import SwiftUI

struct SettingsView: View {
    @State private var isShowingDeleteConfirmation = false

    let onDeleteHistory: () -> Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(role: .destructive) {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Text("settings.delete.history")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { DismissToolbarItem() }
            .confirmationDialog(
                "settings.delete.history.confirmation.title",
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("settings.delete.history.confirm", role: .destructive) {
                    _ = onDeleteHistory()
                }
                Button("common.cancel", role: .cancel) {}
            } message: {
                Text("settings.delete.history.confirmation.message")
                    .multilineTextAlignment(.leading)
            }
        }
    }
}
