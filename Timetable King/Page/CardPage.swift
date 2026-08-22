enum CardPage {
    case todayTasks, weeklySummary, weeklyTasks

    var transitionID: String {
        switch self {
        case .todayTasks: "todayTasks"
        case .weeklySummary: "weeklySummary"
        case .weeklyTasks: "weeklyTasks"
        }
    }
}
