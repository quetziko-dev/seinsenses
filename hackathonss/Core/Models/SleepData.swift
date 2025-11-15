import Foundation
import SwiftData

@Model
final class SleepData {
    var id: UUID
    var bedTime: Date
    var wakeTime: Date
    var totalHours: Double
    var quality: SleepQuality
    var notes: String?
    var date: Date // for the night of
    var source: SleepDataSource // HealthKit or manual entry
    
    @Relationship(inverse: \User.sleepData)
    var user: User?
    
    init(bedTime: Date, wakeTime: Date, quality: SleepQuality, notes: String? = nil, source: SleepDataSource = .manual) {
        self.id = UUID()
        self.bedTime = bedTime
        self.wakeTime = wakeTime
        self.totalHours = wakeTime.timeIntervalSince(bedTime) / 3600
        self.quality = quality
        self.notes = notes
        self.date = Calendar.current.startOfDay(for: bedTime)
        self.source = source
    }
    
    var sleepEfficiency: Double {
        // Assuming optimal sleep is 7-9 hours
        if totalHours >= 7 && totalHours <= 9 {
            return 1.0
        } else if totalHours < 7 {
            return totalHours / 7.0
        } else {
            return 9.0 / totalHours
        }
    }
}

enum SleepQuality: String, CaseIterable, Codable {
    case excellent = "excelente"
    case good = "buena"
    case fair = "regular"
    case poor = "mala"
    
    var color: String {
        switch self {
        case .excellent: return "#4CAF50"
        case .good: return "#8BC34A"
        case .fair: return "#FFC107"
        case .poor: return "#F44336"
        }
    }
}

enum SleepDataSource: String, Codable {
    case healthKit = "health_kit"
    case manual = "manual"
    
    var displayName: String {
        switch self {
        case .healthKit: return "Datos de Salud"
        case .manual: return "Registro Manual"
        }
    }
}
