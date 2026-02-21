import SwiftUI

struct CardEntryView: View {
    let entry: WeekdayHabitResult
    
    var body: some View {
        CardEntryTodoView(entry: entry)
    }
}
