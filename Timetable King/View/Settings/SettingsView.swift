import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingDeleteConfirmation = false

    let onDeleteHistory: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("settings.delete.history", role: .destructive) {
                        isShowingDeleteConfirmation = true
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
                    onDeleteHistory()
                    dismiss()
                }
                Button("common.cancel", role: .cancel) {}
            } message: {
                Text("settings.delete.history.confirmation.message")
            }
        }
    }
}
