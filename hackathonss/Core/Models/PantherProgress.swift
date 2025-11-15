import Foundation
import SwiftData

@Model
final class PantherProgress {
    var id: UUID
    var currentLevel: PantherLevel
    var experiencePoints: Int
    var totalWellnessActivities: Int
    var consecutiveDays: Int
    var lastActiveDate: Date?
    var unlockedFeatures: Set<String> = []
    var evolutionHistory: [PantherEvolution] = []
    
    init() {
        self.id = UUID()
        self.currentLevel = .cub
        self.experiencePoints = 0
        self.totalWellnessActivities = 0
        self.consecutiveDays = 0
    }
    
    var experienceToNextLevel: Int {
        switch currentLevel {
        case .cub: return 100
        case .young: return 250
        case .adult: return 500
        }
    }
    
    var progressPercentage: Double {
        let currentLevelXP = experienceForLevel(currentLevel)
        let nextLevelXP = experienceToNextLevel
        let earnedXP = experiencePoints - currentLevelXP
        return Double(earnedXP) / Double(nextLevelXP)
    }
    
    private func experienceForLevel(_ level: PantherLevel) -> Int {
        switch level {
        case .cub: return 0
        case .young: return 100
        case .adult: return 350
        }
    }
    
    func addExperience(points: Int) {
        experiencePoints += points
        checkLevelUp()
    }
    
    func updateDailyActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastActive = lastActiveDate {
            let lastActiveDay = Calendar.current.startOfDay(for: lastActive)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                consecutiveDays += 1
            } else if daysDifference > 1 {
                consecutiveDays = 1
            }
        } else {
            consecutiveDays = 1
        }
        
        lastActiveDate = today
        totalWellnessActivities += 1
    }
    
    private func checkLevelUp() {
        let currentLevelXP = experienceForLevel(currentLevel)
        let nextLevelXP = currentLevelXP + experienceToNextLevel
        
        if experiencePoints >= nextLevelXP {
            let evolution = PantherEvolution(
                fromLevel: currentLevel,
                toLevel: nextLevel(for: currentLevel),
                date: Date()
            )
            
            evolutionHistory.append(evolution)
            currentLevel = nextLevel(for: currentLevel)
            unlockNewFeatures()
        }
    }
    
    private func nextLevel(for current: PantherLevel) -> PantherLevel {
        switch current {
        case .cub: return .young
        case .young: return .adult
        case .adult: return .adult // Max level
        }
    }
    
    private func unlockNewFeatures() {
        switch currentLevel {
        case .young:
            unlockedFeatures.insert("advanced_analytics")
            unlockedFeatures.insert("custom_panther_outfits")
        case .adult:
            unlockedFeatures.insert("meditation_guides")
            unlockedFeatures.insert("social_sharing")
        case .cub:
            break
        }
    }
}

@Model
final class PantherEvolution {
    var id: UUID
    var fromLevel: PantherLevel
    var toLevel: PantherLevel
    var date: Date
    var celebrationMessage: String
    
    init(fromLevel: PantherLevel, toLevel: PantherLevel, date: Date) {
        self.id = UUID()
        self.fromLevel = fromLevel
        self.toLevel = toLevel
        self.date = date
        self.celebrationMessage = PantherEvolution.generateCelebrationMessage(from: fromLevel, to: toLevel)
    }
    
    private static func generateCelebrationMessage(from: PantherLevel, to: PantherLevel) -> String {
        switch to {
        case .young:
            return "¡Tu pantera ha crecido! Ahora es joven y más enérgica."
        case .adult:
            return "¡Felicidades! Tu pantera ha alcanzado su forma adulta y es sabia y fuerte."
        case .cub:
            return ""
        }
    }
}

enum PantherLevel: String, CaseIterable, Codable {
    case cub = "cachorro"
    case young = "joven"
    case adult = "adulto"
    
    var displayName: String {
        switch self {
        case .cub: return "Pantera Cachorro"
        case .young: return "Pantera Joven"
        case .adult: return "Pantera Adulta"
        }
    }
    
    var assetName: String {
        switch self {
        case .cub: return "panther_cub"
        case .young: return "panther_young"
        case .adult: return "panther_adult"
        }
    }
    
    var description: String {
        switch self {
        case .cub: return "Pequeña, juguetón y llena de curiosidad. Comenzando su viaje de bienestar."
        case .young: return "Enérgica, activa y aprendiendo nuevas habilidades. Siempre lista para la aventura."
        case .adult: return "Sabia, fuerte y equilibrada. Un verdadero maestro del bienestar integral."
        }
    }
}
