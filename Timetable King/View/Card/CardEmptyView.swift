import SwiftUI

struct CardEmptyView: View {
    let errorMessage: LocalizedStringKey
    
    var body: some View {
        Text(errorMessage)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
