import Foundation
import SwiftData

@Model
final class SocialPlan {
    var id: UUID
    var date: Date
    var title: String
    var createdAt: Date
    
    @Relationship(inverse: \User.socialPlans)
    var user: User?
    
    init(date: Date, title: String) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.createdAt = Date()
    }
}
