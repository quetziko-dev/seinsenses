import SwiftUI
import SwiftData

// MARK: - Physical Activity Model
@Model
class PhysicalActivity {
    var id: UUID
    var type: ActivityType
    var duration: Int
    var date: Date
    var caloriesBurned: Int?
    
    @Relationship(inverse: \PhysicalData.activities)
    var physicalData: PhysicalData?
    
    init(type: ActivityType, duration: Int, date: Date, caloriesBurned: Int? = nil) {
        self.id = UUID()
        self.type = type
        self.duration = duration
        self.date = date
        self.caloriesBurned = caloriesBurned
    }
}

// MARK: - Physical Data Model
@Model
class PhysicalData {
    var id: UUID
    var height: Double
    var weight: Double
    var weeklyGoal: Int
    var activityDays: Int
    var lastUpdated: Date
    
    @Relationship(deleteRule: .cascade)
    var activities: [PhysicalActivity] = []
    
    @Relationship(inverse: \User.physicalData)
    var user: User?
    
    init(height: Double, weight: Double, weeklyGoal: Int) {
        self.id = UUID()
        self.height = height
        self.weight = weight
        self.weeklyGoal = weeklyGoal
        self.activityDays = 0
        self.lastUpdated = Date()
    }
    
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
}

enum ActivityType: String, CaseIterable, Codable {
    case walking = "caminar"
    case running = "correr"
    case cycling = "ciclismo"
    case swimming = "natación"
    case yoga = "yoga"
    case gym = "gimnasio"
    case sports = "deportes"
    case other = "otro"
}
