import Foundation
import SwiftData

@Model
final class DailyProgress {
    @Attribute(.unique) var id: UUID = UUID()
    var date: Date
    var completion: Bool
    var challenge: Challenge
    
    init(date: Date, completion: Bool, challenge: Challenge) {
        self.date = date
        self.completion = completion
        self.challenge = challenge
    }
}
    
    
