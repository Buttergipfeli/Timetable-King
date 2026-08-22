struct CompletionScore: Equatable, Sendable {
    let completedCount: Int
    let totalCount: Int

    var completionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var performanceEmoji: String {
        guard totalCount > 0 else { return "😶" }

        return switch completionPercentage {
        case 0: "😭"
        case 0..<0.25: "😢"
        case 0.25..<0.5: "😬"
        case 0.5..<0.75: "🙂"
        case 0.75..<1.0: "😄"
        default: "🤩"
        }
    }
}
