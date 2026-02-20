import SwiftUI

struct CardTitleView: View {
    let title: LocalizedStringKey
    
    var body: some View {
        Text(title)
            .font(.title2)
    }
}
