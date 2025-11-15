import SwiftUI
import SwiftData

// MARK: - Emotion Response Model
@Model
class EmotionResponse {
    var id: UUID
    var question: String
    var answer: String
    var timestamp: Date
    
    @Relationship(inverse: \EmotionData.responses)
    var emotionData: EmotionData?
    
    init(question: String, answer: String) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.timestamp = Date()
    }
}

// MARK: - Emotion Data Model
@Model
class EmotionData {
    var id: UUID
    var emotion: EmotionType
    var intensity: Double
    var date: Date
    var reflectionNotes: String?
    
    @Relationship(deleteRule: .cascade)
    var responses: [EmotionResponse] = []
    
    @Relationship(deleteRule: .cascade)
    var aiAnalysis: AIEmotionAnalysisResult?
    
    @Relationship(inverse: \User.emotions)
    var user: User?
    
    init(emotion: EmotionType, intensity: Double, responses: [EmotionResponse]) {
        self.id = UUID()
        self.emotion = emotion
        self.intensity = intensity
        self.date = Date()
        
        for response in responses {
            response.emotionData = self
            self.responses.append(response)
        }
    }
}

enum EmotionType: String, CaseIterable, Codable {
    case happy = "feliz"
    case sad = "triste"
    case anxious = "ansioso"
    case angry = "enojado"
    case grateful = "agradecido"
    case peaceful = "pacífico"
    case stressed = "estresado"
    case excited = "emocionado"
    case tired = "cansado"
    case confused = "confundido"
    
    var color: String {
        switch self {
        case .happy: return "#FFD700"
        case .sad: return "#4682B4"
        case .anxious: return "#FF69B4"
        case .angry: return "#DC143C"
        case .grateful: return "#98FB98"
        case .peaceful: return "#87CEEB"
        case .stressed: return "#FF8C00"
        case .excited: return "#FF1493"
        case .tired: return "#708090"
        case .confused: return "#9370DB"
        }
    }
    
    var icon: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .angry: return "😠"
        case .grateful: return "🙏"
        case .peaceful: return "😌"
        case .stressed: return "😣"
        case .excited: return "🤗"
        case .tired: return "😴"
        case .confused: return "😕"
        }
    }
}
