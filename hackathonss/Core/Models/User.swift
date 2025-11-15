import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var name: String
    var nickname: String? // Optional custom nickname
    var avatarPath: String? // Optional profile photo path
    var createdAt: Date
    var physicalData: PhysicalData?
    var sleepData: [SleepData] = []
    var emotions: [EmotionData] = []
    var moodJar: MoodJar?
    var pantherProgress: PantherProgress
    var physicalProfile: PhysicalProfile?
    var generatedPlans: GeneratedPlans?
    var journalEntries: [JournalEntry] = []
    var socialPlans: [SocialPlan] = []
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.nickname = nil
        self.avatarPath = nil
        self.createdAt = Date()
        self.pantherProgress = PantherProgress()
    }
    
    // Computed property to get display name (nickname if set, otherwise name)
    var displayName: String {
        return nickname ?? name
    }
}
