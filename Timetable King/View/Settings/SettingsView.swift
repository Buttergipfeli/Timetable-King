import SwiftUI

struct SettingsView: View {
    @Environment(\.appTheme) private var theme
    @Environment(AppPaletteStore.self) private var paletteStore

    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingOnboarding = false
    @State private var reminderService = TaskReminderService.shared

    let onDeleteHistory: () -> Bool
    let onAddTask: (String, Set<Weekday>, Int, Int, TaskReminder) -> Bool

    var body: some View {
        NavigationStack {
            List {
                Section("settings.appearance") {
                    HStack(spacing: .paletteSpacing) {
                        palettePreview

                        VStack(alignment: .leading, spacing: .paletteTextSpacing) {
                            Text("settings.palette.title")
                                .font(.headline)

                            Text("settings.palette.id".localized(paletteStore.palette.id))
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("settings.palette.identifier")
                        }
                    }

                    Text("settings.palette.description")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button {
                        paletteStore.generatePalette()
                    } label: {
                        Label("settings.palette.generate", systemImage: "wand.and.sparkles")
                    }
                    .accessibilityIdentifier("settings.palette.generate.button")
                }

                Section {
                    Button {
                        isShowingOnboarding = true
                    } label: {
                        Label("settings.onboarding", systemImage: "sparkles")
                    }
                    .accessibilityIdentifier("settings.onboarding.button")
                }

                Section("task.reminder.title") {
                    Text("task.reminder.scheduling.description")
                    if reminderService.hasSchedulingError {
                        Text("task.reminder.error")
                            .foregroundStyle(.red)
                    }
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        Link("task.reminder.open.settings", destination: url)
                    }
                }

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
            .fullScreenCover(isPresented: $isShowingOnboarding) {
                OnboardingView(onSave: onAddTask) {
                    isShowingOnboarding = false
                }
            }
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

    private var palettePreview: some View {
        HStack(spacing: .swatchOverlap) {
            Circle()
                .fill(theme.accent)
            Circle()
                .fill(theme.secondaryAccent)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [theme.logoPrimary, theme.logoSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .frame(width: .previewWidth, height: .swatchSize)
    }
}

private extension CGFloat {
    static let paletteSpacing = 14.0
    static let paletteTextSpacing = 2.0
    static let swatchOverlap = -6.0
    static let previewWidth = 80.0
    static let swatchSize = 32.0
}
