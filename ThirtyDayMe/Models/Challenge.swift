import Foundation
import SwiftData

@Model
final class Challenge {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var wish: String
    var dailyAction: String
    var emoji: String = "✅"
    var startDate: Date
    var endDate: Date
    @Relationship(deleteRule: .cascade, inverse: \DailyProgress.challenge)
    var dailyProgress: [DailyProgress] = []
    
    init(
        title: String,
        wish: String,
        dailyAction: String,
        emoji: String,
        startDate: Date,
        endDate: Date
    ) {
        self.title = title
        self.wish = wish
        self.dailyAction = dailyAction
        self.emoji = emoji
        self.startDate = startDate
        self.endDate = endDate
    }
}
