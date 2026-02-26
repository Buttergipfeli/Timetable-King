struct WeekdayBucket<Item: WeekdayHabitable> {
    let weekday: Weekday
    let items: [Item]
    
    func appending(_ item: Item) -> WeekdayBucket {
        WeekdayBucket(weekday: weekday, items: items + [item])
    }
    
    static func empty(_ weekday: Weekday) -> WeekdayBucket<Item> {
        WeekdayBucket(weekday: weekday, items: [])
    }
}

extension WeekdayBucket: Identifiable {
    var id: String {
        "\(weekday.rawValue)\(Item.self)"
    }
}
