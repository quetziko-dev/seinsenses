import Foundation

// MARK: - Physical AI Service Protocol
protocol PhysicalAIServiceProtocol {
    func generateWorkoutAndDiet(for profile: PhysicalProfile) async throws -> (WorkoutPlan, DietPlan)
}

// MARK: - Physical AI Service Implementation
/// Servicio para generar planes de ejercicio y dieta personalizados usando IA
/// 
/// ⚠️ DISCLAIMER IMPORTANTE:
/// Las recomendaciones generadas son sugerencias generales de estilo de vida
/// NO son asesoría médica, nutricional o de entrenamiento profesional
/// El usuario debe consultar a profesionales de salud antes de cambios importantes
/// 
/// 🔮 FUTURO - Integración con IA Real:
/// Para conectar con OpenAI u otra API:
/// 1. Crear cuenta en OpenAI y obtener API key
/// 2. Agregar dependencia (por ejemplo, OpenAI Swift SDK)
/// 3. Reemplazar MockPhysicalAIService con ProductionPhysicalAIService
/// 4. El prompt ya está optimizado y listo para usar
/// 5. NUNCA exponer API keys en el código (usar backend o secrets manager)
@MainActor
final class MockPhysicalAIService: PhysicalAIServiceProtocol {
    static let shared = MockPhysicalAIService()
    
    private init() {}
    
    func generateWorkoutAndDiet(for profile: PhysicalProfile) async throws -> (WorkoutPlan, DietPlan) {
        // Simular latencia de red (como si llamáramos a una API)
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
        
        // Generar planes personalizados basados en el perfil
        let workout = generateWorkoutPlan(for: profile)
        let diet = generateDietPlan(for: profile)
        
        print("✅ Planes generados para objetivo: \(profile.goal.displayName)")
        return (workout, diet)
    }
    
    // MARK: - Workout Plan Generation
    
    private func generateWorkoutPlan(for profile: PhysicalProfile) -> WorkoutPlan {
        let location = profile.workoutLocation
        let daysPerWeek = profile.activityDaysPerWeek
        let duration = profile.sessionDurationMinutes
        
        var summary: String
        var focusAreas: [String]
        var dailyPlan: [WorkoutPlan.DayWorkout]
        
        switch profile.goal {
        case .loseWeight:
            summary = "Rutina enfocada en quema de calorías con combinación de cardio y fuerza. \(daysPerWeek) días por semana, \(duration) minutos por sesión."
            focusAreas = ["Cardio de alta intensidad", "Fuerza de cuerpo completo", "Core y estabilidad"]
            dailyPlan = generateLoseWeightPlan(location: location, days: daysPerWeek)
            
        case .gainMuscle:
            summary = "Rutina de hipertrofia muscular con enfoque en fuerza progresiva. \(daysPerWeek) días por semana, \(duration) minutos por sesión."
            focusAreas = ["Fuerza con pesas", "Hipertrofia muscular", "Descanso activo"]
            dailyPlan = generateGainMusclePlan(location: location, days: daysPerWeek)
            
        case .improveEndurance:
            summary = "Rutina cardiovascular para mejorar resistencia y capacidad aeróbica. \(daysPerWeek) días por semana, \(duration) minutos por sesión."
            focusAreas = ["Cardio progresivo", "Resistencia muscular", "Flexibilidad"]
            dailyPlan = generateEndurancePlan(location: location, days: daysPerWeek)
            
        case .maintainWeight:
            summary = "Rutina balanceada para mantener peso y condición física. \(daysPerWeek) días por semana, \(duration) minutos por sesión."
            focusAreas = ["Ejercicio equilibrado", "Cardio moderado", "Fuerza funcional"]
            dailyPlan = generateMaintainPlan(location: location, days: daysPerWeek)
            
        case .generalHealth:
            summary = "Rutina integral para salud general y bienestar. \(daysPerWeek) días por semana, \(duration) minutos por sesión."
            focusAreas = ["Movilidad", "Fuerza funcional", "Cardio saludable"]
            dailyPlan = generateGeneralHealthPlan(location: location, days: daysPerWeek)
        }
        
        return WorkoutPlan(
            summary: summary,
            sessionsPerWeek: daysPerWeek,
            sessionDurationMinutes: duration,
            focusAreas: focusAreas,
            dailyPlan: dailyPlan
        )
    }
    
    // MARK: - Diet Plan Generation
    
    private func generateDietPlan(for profile: PhysicalProfile) -> DietPlan {
        let bmr = calculateBMR(profile: profile)
        let tdee = calculateTDEE(bmr: bmr, activityLevel: profile.activityDaysPerWeek)
        
        var targetCalories: Int
        var proteinGrams: Int
        var carbsGrams: Int
        var fatsGrams: Int
        var guidelines: [String]
        var mealPlan: DietPlan.MealPlan
        
        switch profile.goal {
        case .loseWeight:
            targetCalories = Int(tdee * 0.8) // Déficit del 20%
            proteinGrams = Int(profile.weightKg * 1.8)
            fatsGrams = Int(Double(targetCalories) * 0.25 / 9)
            carbsGrams = Int((Double(targetCalories) - Double(proteinGrams * 4) - Double(fatsGrams * 9)) / 4)
            
            guidelines = [
                "Déficit calórico moderado de ~20%",
                "Alta proteína para preservar músculo",
                "Priorizar alimentos enteros y saciantes",
                "Mantenerse hidratado (2-3L agua al día)",
                "Evitar azúcares añadidos y alimentos procesados"
            ]
            mealPlan = loseWeightMealPlan
            
        case .gainMuscle:
            targetCalories = Int(tdee * 1.15) // Superávit del 15%
            proteinGrams = Int(profile.weightKg * 2.0)
            fatsGrams = Int(Double(targetCalories) * 0.25 / 9)
            carbsGrams = Int((Double(targetCalories) - Double(proteinGrams * 4) - Double(fatsGrams * 9)) / 4)
            
            guidelines = [
                "Superávit calórico moderado de ~15%",
                "Muy alta proteína para construcción muscular",
                "Carbohidratos suficientes para energía",
                "Comidas frecuentes (4-6 al día)",
                "Timing: proteína post-entrenamiento"
            ]
            mealPlan = gainMuscleMealPlan
            
        case .improveEndurance:
            targetCalories = Int(tdee)
            proteinGrams = Int(profile.weightKg * 1.4)
            fatsGrams = Int(Double(targetCalories) * 0.25 / 9)
            carbsGrams = Int((Double(targetCalories) - Double(proteinGrams * 4) - Double(fatsGrams * 9)) / 4)
            
            guidelines = [
                "Calorías de mantenimiento",
                "Carbohidratos para energía sostenida",
                "Proteína moderada para recuperación",
                "Hidratación constante",
                "Electrolitos durante ejercicio prolongado"
            ]
            mealPlan = enduranceMealPlan
            
        case .maintainWeight, .generalHealth:
            targetCalories = Int(tdee)
            proteinGrams = Int(profile.weightKg * 1.6)
            fatsGrams = Int(Double(targetCalories) * 0.28 / 9)
            carbsGrams = Int((Double(targetCalories) - Double(proteinGrams * 4) - Double(fatsGrams * 9)) / 4)
            
            guidelines = [
                "Calorías de mantenimiento",
                "Dieta balanceada y variada",
                "Incluir frutas y verduras diariamente",
                "Grasas saludables (aguacate, nueces, aceite de oliva)",
                "Moderación en alimentos procesados"
            ]
            mealPlan = generalHealthMealPlan
        }
        
        return DietPlan(
            summary: "Plan nutricional personalizado con ~\(targetCalories) kcal/día para tu objetivo de \(profile.goal.displayName.lowercased())",
            caloriesApprox: targetCalories,
            proteinGramsApprox: proteinGrams,
            carbsGramsApprox: carbsGrams,
            fatsGramsApprox: fatsGrams,
            guidelines: guidelines,
            exampleDayMenu: mealPlan
        )
    }
    
    // MARK: - Helper Functions
    
    private func calculateBMR(profile: PhysicalProfile) -> Double {
        // Fórmula de Mifflin-St Jeor
        let heightCm = profile.heightCm
        let weightKg = profile.weightKg
        let age = Double(profile.age ?? 30)
        
        // Usar valor neutro si no hay sexo especificado
        let sexModifier: Double = profile.sex == "male" ? 5 : (profile.sex == "female" ? -161 : -78)
        
        return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + sexModifier
    }
    
    private func calculateTDEE(bmr: Double, activityLevel: Int) -> Double {
        let activityMultiplier: Double
        switch activityLevel {
        case 1...2: activityMultiplier = 1.375 // Ligera
        case 3...4: activityMultiplier = 1.55  // Moderada
        case 5...6: activityMultiplier = 1.725 // Activa
        default: activityMultiplier = 1.9      // Muy activa
        }
        return bmr * activityMultiplier
    }
    
    // MARK: - Workout Plan Templates
    
    private func generateLoseWeightPlan(location: String, days: Int) -> [WorkoutPlan.DayWorkout] {
        let isGym = location == "gym"
        return [
            WorkoutPlan.DayWorkout(
                day: "Lunes",
                description: "Cardio HIIT + Core",
                exercises: isGym
                    ? ["Calentamiento: 5 min caminadora", "Intervalos HIIT: 20 min", "Abdominales: 3x15", "Planchas: 3x30seg"]
                    : ["Saltos de tijera: 3 min", "Burpees: 4x10", "Mountain climbers: 3x20", "Planchas: 3x30seg"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Miércoles",
                description: "Fuerza de cuerpo completo",
                exercises: isGym
                    ? ["Sentadillas: 4x12", "Press de pecho: 3x12", "Remo: 3x12", "Peso muerto: 3x10"]
                    : ["Sentadillas: 4x15", "Flexiones: 3x12", "Dominadas asistidas: 3x8", "Zancadas: 3x12 c/pierna"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Viernes",
                description: "Cardio steady state",
                exercises: ["Trote/bici: 30-40 min zona 2", "Estiramiento: 10 min"]
            )
        ].prefix(days).map { $0 }
    }
    
    private func generateGainMusclePlan(location: String, days: Int) -> [WorkoutPlan.DayWorkout] {
        let isGym = location == "gym"
        return [
            WorkoutPlan.DayWorkout(
                day: "Lunes",
                description: "Pecho y tríceps",
                exercises: isGym
                    ? ["Press banca: 4x8", "Press inclinado: 3x10", "Fondos: 3x12", "Extensiones tríceps: 3x12"]
                    : ["Flexiones: 4x15", "Flexiones diamante: 3x10", "Fondos en silla: 3x12"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Miércoles",
                description: "Espalda y bíceps",
                exercises: isGym
                    ? ["Peso muerto: 4x6", "Dominadas: 3x8", "Remo con barra: 3x10", "Curl barra: 3x12"]
                    : ["Dominadas/asistidas: 4x8", "Remo invertido: 3x12", "Curl con mancuernas: 3x12"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Viernes",
                description: "Piernas y hombros",
                exercises: isGym
                    ? ["Sentadilla: 4x8", "Prensa: 3x12", "Press militar: 3x10", "Elevaciones laterales: 3x15"]
                    : ["Sentadillas con peso: 4x12", "Zancadas: 3x12", "Flexiones pike: 3x10"]
            )
        ].prefix(days).map { $0 }
    }
    
    private func generateEndurancePlan(location: String, days: Int) -> [WorkoutPlan.DayWorkout] {
        [
            WorkoutPlan.DayWorkout(
                day: "Lunes",
                description: "Cardio base",
                exercises: ["Trote suave: 30 min", "Estiramientos: 10 min"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Miércoles",
                description: "Intervalos",
                exercises: ["Calentamiento: 10 min", "5x (3 min rápido + 2 min recuperación)", "Enfriamiento: 10 min"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Sábado",
                description: "Carrera larga",
                exercises: ["Trote constante: 45-60 min", "Estiramientos: 15 min"]
            )
        ].prefix(days).map { $0 }
    }
    
    private func generateMaintainPlan(location: String, days: Int) -> [WorkoutPlan.DayWorkout] {
        [
            WorkoutPlan.DayWorkout(
                day: "Lunes",
                description: "Fuerza general",
                exercises: ["Sentadillas: 3x12", "Flexiones: 3x12", "Remo: 3x12", "Planchas: 3x30seg"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Miércoles",
                description: "Cardio moderado",
                exercises: ["Trote/bici: 25 min", "Core: 10 min"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Viernes",
                description: "Circuito completo",
                exercises: ["3 rondas de:", "10 burpees", "15 sentadillas", "10 flexiones", "30seg plancha"]
            )
        ].prefix(days).map { $0 }
    }
    
    private func generateGeneralHealthPlan(location: String, days: Int) -> [WorkoutPlan.DayWorkout] {
        [
            WorkoutPlan.DayWorkout(
                day: "Lunes",
                description: "Movilidad y fuerza",
                exercises: ["Yoga/estiramientos: 15 min", "Sentadillas: 2x15", "Flexiones: 2x10"]
            ),
            WorkoutPlan.DayWorkout(
                day: "Jueves",
                description: "Caminata activa",
                exercises: ["Caminata rápida: 30 min", "Ejercicios de balance"]
            )
        ].prefix(days).map { $0 }
    }
    
    // MARK: - Meal Plan Templates
    
    private var loseWeightMealPlan: DietPlan.MealPlan {
        DietPlan.MealPlan(
            breakfast: ["Claras de huevo revueltas (3-4)", "Avena (40g) con frutos rojos", "Café negro o té verde"],
            midMorningSnack: ["Yogurt griego bajo en grasa (150g)", "10 almendras"],
            lunch: ["Pechuga de pollo (150g) a la plancha", "Ensalada verde grande", "Arroz integral (50g cocido)"],
            afternoonSnack: ["Manzana", "Queso cottage (100g)"],
            dinner: ["Pescado blanco (150g)", "Verduras al vapor", "Ensalada mixta"]
        )
    }
    
    private var gainMuscleMealPlan: DietPlan.MealPlan {
        DietPlan.MealPlan(
            breakfast: ["4 huevos completos", "Avena (60g) con plátano", "Jugo de naranja natural"],
            midMorningSnack: ["Batido de proteína con plátano", "Crema de cacahuate (2 cucharadas)"],
            lunch: ["Carne magra (200g)", "Arroz blanco (100g cocido)", "Aguacate (1/2)", "Verduras cocidas"],
            afternoonSnack: ["Yogurt griego (200g)", "Granola (30g)", "Frutos secos (30g)"],
            dinner: ["Salmón (180g)", "Camote asado (150g)", "Brócoli al vapor", "Ensalada con aceite de oliva"]
        )
    }
    
    private var enduranceMealPlan: DietPlan.MealPlan {
        DietPlan.MealPlan(
            breakfast: ["Avena (50g) con plátano", "2 huevos", "Pan integral con miel"],
            midMorningSnack: ["Barrita energética", "Plátano"],
            lunch: ["Pasta integral (100g)", "Pollo (120g)", "Salsa de tomate", "Ensalada"],
            afternoonSnack: ["Smoothie de frutas", "Galletas de avena"],
            dinner: ["Pescado (150g)", "Quinoa (80g)", "Verduras variadas"]
        )
    }
    
    private var generalHealthMealPlan: DietPlan.MealPlan {
        DietPlan.MealPlan(
            breakfast: ["Avena con frutas", "Yogurt natural", "Té verde"],
            midMorningSnack: ["Fruta de temporada", "Puñado de nueces"],
            lunch: ["Proteína magra (pollo/pescado)", "Arroz o quinoa", "Verduras variadas", "Ensalada"],
            afternoonSnack: ["Hummus con vegetales", "Galletas integrales"],
            dinner: ["Sopa de verduras", "Pechuga a la plancha", "Ensalada verde"]
        )
    }
}

// MARK: - Production Service Structure (Para futuro)
/// Estructura para cuando se conecte con IA real
final class ProductionPhysicalAIService: PhysicalAIServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateWorkoutAndDiet(for profile: PhysicalProfile) async throws -> (WorkoutPlan, DietPlan) {
        // TODO: Implementar cuando se tenga backend/API key segura
        // El prompt está listo para usar
        let prompt = buildPrompt(for: profile)
        
        // Por ahora, delegar al mock
        return try await MockPhysicalAIService.shared.generateWorkoutAndDiet(for: profile)
    }
    
    private func buildPrompt(for profile: PhysicalProfile) -> String {
        """
        Eres un asistente de bienestar que genera recomendaciones generales de ejercicio y nutrición.
        
        IMPORTANTE - DISCLAIMER:
        - Estas son sugerencias generales de estilo de vida
        - NO son asesoría médica, nutricional o de entrenamiento profesional
        - El usuario debe consultar a profesionales de salud antes de cambios importantes
        - Adapta el volumen e intensidad a un nivel intermedio/moderado
        
        PERFIL DEL USUARIO:
        - Objetivo: \(profile.goal.displayName)
        - Altura: \(profile.heightCm) cm
        - Peso: \(profile.weightKg) kg
        - Edad: \(profile.age ?? 30) años
        - Días de entrenamiento: \(profile.activityDaysPerWeek) por semana
        - Duración de sesión: \(profile.sessionDurationMinutes) minutos
        - Entrena en: \(profile.workoutLocation == "gym" ? "gimnasio" : "casa")
        
        Genera:
        1. Un plan de ejercicio con rutinas específicas por día
        2. Un plan de alimentación con macros aproximados y ejemplo de menú
        
        Formato JSON con estructura WorkoutPlan y DietPlan.
        """
    }
}
