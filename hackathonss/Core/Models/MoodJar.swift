import SwiftUI
import SwiftData

// MARK: - Mood Marble Model
@Model
class MoodMarble {
    var id: UUID
    var emotion: EmotionType
    var intensity: Double
    var date: Date
    var x: Double
    var y: Double
    var z: Double
    
    @Relationship(inverse: \MoodJar.marbles)
    var moodJar: MoodJar?
    
    init(emotion: EmotionType, intensity: Double, position: MarblePosition) {
        self.id = UUID()
        self.emotion = emotion
        self.intensity = intensity
        self.date = Date()
        self.x = position.x
        self.y = position.y
        self.z = position.z
    }
    
    var position: MarblePosition {
        get { MarblePosition(x: x, y: y, z: z) }
        set { 
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}

// MARK: - Mood Jar Model
@Model
class MoodJar {
    var id: UUID
    var createdDate: Date
    var maxCapacity: Int
    
    @Relationship(deleteRule: .cascade)
    var marbles: [MoodMarble] = []
    
    @Relationship(inverse: \User.moodJar)
    var user: User?
    
    init() {
        self.id = UUID()
        self.createdDate = Date()
        self.maxCapacity = 30
    }
    
    // MARK: - Methods
    func addMarble(emotion: EmotionType, intensity: Double) {
        let position = generateRandomPosition()
        let marble = MoodMarble(emotion: emotion, intensity: intensity, position: position)
        marble.moodJar = self
        
        marbles.append(marble)
        
        // Keep only the most recent marbles
        if marbles.count > maxCapacity {
            marbles.removeFirst()
        }
    }
    
    private func generateRandomPosition() -> MarblePosition {
        let angle = Double.random(in: 0...(2 * .pi))
        let radius = Double.random(in: 0...0.8)
        let height = Double.random(in: -0.8...0.8)
        
        return MarblePosition(
            x: radius * cos(angle),
            y: height,
            z: radius * sin(angle)
        )
    }
    
    var currentMood: EmotionType? {
        return marbles.last?.emotion
    }
    
    var moodTrend: [EmotionType] {
        return Array(marbles.suffix(7).map { $0.emotion })
    }
    
    func getMarblesByEmotion(_ emotion: EmotionType) -> [MoodMarble] {
        return marbles.filter { $0.emotion == emotion }
    }
    
    func clearOldMarbles(olderThan days: Int) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        marbles.removeAll { $0.date < cutoffDate }
    }
}

// MARK: - Marble Position Struct
struct MarblePosition: Codable {
    var x: Double
    var y: Double
    var z: Double
    
    init(x: Double = 0, y: Double = 0, z: Double = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
}
