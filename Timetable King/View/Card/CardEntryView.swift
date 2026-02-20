import SwiftUI

struct CardEntryView: View {
    let entry: WeekdayHabit
    
    var body: some View {
        if entry.results.filter(\.day.isToday).first?.isDone == true {
            EmptyView()
        } else {
            CardEntryTodoView(entry: entry)
        }
    }
}
