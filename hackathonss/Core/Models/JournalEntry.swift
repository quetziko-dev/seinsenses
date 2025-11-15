import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var text: String
    var createdAt: Date
    
    @Relationship(inverse: \User.journalEntries)
    var user: User?
    
    init(text: String) {
        self.id = UUID()
        self.date = Date()
        self.text = text
        self.createdAt = Date()
    }
}
