import SwiftUI

struct OnboardingView: View {
    @Environment(\.appTheme) private var theme

    let onSave: (String, Weekday, Int, Int) -> Bool
    let onFinish: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    introduction

                    VStack(alignment: .leading, spacing: 24) {
                        feature(
                            title: "onboarding.plan.title",
                            description: "onboarding.plan.description",
                            symbol: "calendar"
                        )
                        feature(
                            title: "onboarding.today.title",
                            description: "onboarding.today.description",
                            symbol: "checkmark.circle"
                        )
                        feature(
                            title: "onboarding.review.title",
                            description: "onboarding.review.description",
                            symbol: "chart.bar.xaxis"
                        )
                    }
                }
                .frame(maxWidth: 520, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Timetable King")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("onboarding.skip", action: onFinish)
                        .accessibilityIdentifier("onboarding.skip.button")
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    NavigationLink {
                        OnboardingRoutineView(onSave: onSave, onFinish: onFinish)
                    } label: {
                        Text("onboarding.start")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 18))
                    .accessibilityIdentifier("onboarding.start.button")

                    Text("onboarding.footer")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: 520)
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(
                        colors: [theme.logoPrimary, theme.logoSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 26)
                )
                .accessibilityHidden(true)

            Text("onboarding.welcome.title")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("onboarding.welcome.title")

            Text("onboarding.welcome.description")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private func feature(
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        symbol: String
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(theme.accent)
                .frame(width: 48, height: 48)
                .background(theme.accentSurface, in: RoundedRectangle(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
