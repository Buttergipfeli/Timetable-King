extension String {
    var firstLetterUppercased: String {
        prefix(1).uppercased() + dropFirst()
    }
}
