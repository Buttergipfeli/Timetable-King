import SwiftUI

struct DashboardSurface<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(.primary.opacity(.borderOpacity), lineWidth: 1)
            }
    }
}

private extension CGFloat {
    static let cornerRadius = 22.0
}

private extension Double {
    static let borderOpacity = 0.06
}
