import Foundation
import SwiftData

// MARK: - Fitness Goal
enum FitnessGoal: String, Codable, CaseIterable {
    case loseWeight = "lose_weight"
    case maintainWeight = "maintain_weight"
    case gainMuscle = "gain_muscle"
    case improveEndurance = "improve_endurance"
    case generalHealth = "general_health"
    
    var displayName: String {
        switch self {
        case .loseWeight: return "Bajar de peso"
        case .maintainWeight: return "Mantener mi peso"
        case .gainMuscle: return "Ganar músculo"
        case .improveEndurance: return "Mejorar resistencia"
        case .generalHealth: return "Mejorar salud general"
        }
    }
    
    var icon: String {
        switch self {
        case .loseWeight: return "arrow.down.circle.fill"
        case .maintainWeight: return "equal.circle.fill"
        case .gainMuscle: return "arrow.up.circle.fill"
        case .improveEndurance: return "figure.run"
        case .generalHealth: return "heart.fill"
        }
    }
}

// MARK: - Physical Profile
@Model
final class PhysicalProfile {
    var id: UUID
    var heightCm: Double
    var weightKg: Double
    var age: Int?
    var sex: String? // "male", "female", "other", or nil
    var activityDaysPerWeek: Int
    var sessionDurationMinutes: Int
    var workoutLocation: String // "gym" or "home"
    var goal: FitnessGoal
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \User.physicalProfile)
    var user: User?
    
    init(
        heightCm: Double,
        weightKg: Double,
        age: Int? = nil,
        sex: String? = nil,
        activityDaysPerWeek: Int,
        sessionDurationMinutes: Int,
        workoutLocation: String,
        goal: FitnessGoal
    ) {
        self.id = UUID()
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.age = age
        self.sex = sex
        self.activityDaysPerWeek = activityDaysPerWeek
        self.sessionDurationMinutes = sessionDurationMinutes
        self.workoutLocation = workoutLocation
        self.goal = goal
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var bmi: Double {
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Bajo peso"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Sobrepeso"
        default: return "Obesidad"
        }
    }
}

// MARK: - Workout Plan
struct WorkoutPlan: Identifiable, Codable {
    var id: UUID = UUID()
    var summary: String
    var sessionsPerWeek: Int
    var sessionDurationMinutes: Int
    var focusAreas: [String]
    var dailyPlan: [DayWorkout]
    var generatedAt: Date = Date()
    
    struct DayWorkout: Codable, Identifiable {
        var id = UUID()
        var day: String // "Lunes", "Martes", etc.
        var description: String
        var exercises: [String]
    }
}

// MARK: - Diet Plan
struct DietPlan: Identifiable, Codable {
    var id: UUID = UUID()
    var summary: String
    var caloriesApprox: Int?
    var proteinGramsApprox: Int?
    var carbsGramsApprox: Int?
    var fatsGramsApprox: Int?
    var guidelines: [String]
    var exampleDayMenu: MealPlan
    var generatedAt: Date = Date()
    
    struct MealPlan: Codable {
        var breakfast: [String]
        var midMorningSnack: [String]
        var lunch: [String]
        var afternoonSnack: [String]
        var dinner: [String]
    }
}

// MARK: - AI Generated Plans Container
@Model
final class GeneratedPlans {
    var id: UUID
    var workoutPlanData: Data?
    var dietPlanData: Data?
    var createdAt: Date
    
    @Relationship(inverse: \User.generatedPlans)
    var user: User?
    
    init() {
        self.id = UUID()
        self.createdAt = Date()
    }
    
    var workoutPlan: WorkoutPlan? {
        get {
            guard let data = workoutPlanData else { return nil }
            return try? JSONDecoder().decode(WorkoutPlan.self, from: data)
        }
        set {
            workoutPlanData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var dietPlan: DietPlan? {
        get {
            guard let data = dietPlanData else { return nil }
            return try? JSONDecoder().decode(DietPlan.self, from: data)
        }
        set {
            dietPlanData = try? JSONEncoder().encode(newValue)
        }
    }
}
