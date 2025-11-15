import Foundation

// MARK: - Volunteer Suggestion Model
struct VolunteerSuggestion: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: String
    
    var categoryColor: String {
        switch category.lowercased() {
        case "educación": return "#4CAF50"
        case "ambiental": return "#2196F3"
        case "comunitario": return "#FF9800"
        case "salud": return "#F44336"
        default: return "#9C27B0"
        }
    }
    
    init(id: UUID = UUID(), title: String, description: String, category: String) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
    }
}

// MARK: - Volunteer AI Service Protocol
protocol VolunteerAIServiceProtocol {
    func suggestVolunteerActivities(for profile: UserProfile?) async throws -> [VolunteerSuggestion]
}

// Simple user profile for context
struct UserProfile {
    let interests: [String]?
    let location: String?
}

// MARK: - Mock Volunteer AI Service
/// Servicio de IA para sugerir oportunidades de voluntariado
///
/// ⚠️ DISCLAIMER:
/// Las sugerencias son opciones generales de voluntariado social
/// Inspiradas en el compromiso social universitario (tipo UP)
/// NO incluyen actividades peligrosas ni políticas
///
/// 🔮 FUTURO - IA Real:
/// Para conectar con OpenAI u otra API:
/// 1. Crear backend que maneje API keys de forma segura
/// 2. Enviar perfil del usuario (intereses, ubicación)
/// 3. IA genera sugerencias personalizadas basadas en:
///    - Intereses del usuario
///    - Ubicación geográfica
///    - Disponibilidad de tiempo
///    - Causas sociales prioritarias
/// 4. Backend valida y filtra sugerencias
/// 5. NUNCA exponer API keys en la app
///
/// Prompt sugerido para IA:
/// ```
/// Genera 5 sugerencias de voluntariado para un usuario con:
/// - Intereses: [lista]
/// - Ubicación: [ciudad]
/// 
/// Requisitos:
/// - Actividades seguras y accesibles
/// - Inspiradas en compromiso social universitario
/// - Categorías: educación, ambiental, comunitario, salud
/// - Descripción clara y motivante
/// - NO incluir actividades peligrosas ni políticas
/// - Enfoque en impacto positivo local
/// ```
@MainActor
final class MockVolunteerAIService: VolunteerAIServiceProtocol {
    static let shared = MockVolunteerAIService()
    
    private init() {}
    
    func suggestVolunteerActivities(for profile: UserProfile?) async throws -> [VolunteerSuggestion] {
        // Simular latencia de IA
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 segundos
        
        // Sugerencias inspiradas en compromiso social UP
        let suggestions = [
            VolunteerSuggestion(
                title: "Alfabetización para adultos",
                description: "Apoya a adultos en su proceso de aprendizaje de lectura y escritura. Sesiones de 2 horas los fines de semana en centros comunitarios.",
                category: "Educación"
            ),
            VolunteerSuggestion(
                title: "Limpieza de parques locales",
                description: "Participa en jornadas de limpieza y reforestación de espacios públicos. Contribuye al cuidado del medio ambiente en tu comunidad.",
                category: "Ambiental"
            ),
            VolunteerSuggestion(
                title: "Acompañamiento a adultos mayores",
                description: "Visita asilos y casas de retiro para conversar y acompañar a personas de la tercera edad. Tu tiempo puede alegrar su día.",
                category: "Comunitario"
            ),
            VolunteerSuggestion(
                title: "Banco de alimentos",
                description: "Ayuda en la clasificación y distribución de alimentos para familias en situación vulnerable. Comprometemos 4 horas al mes.",
                category: "Comunitario"
            ),
            VolunteerSuggestion(
                title: "Tutorías académicas",
                description: "Ofrece apoyo educativo a niños y jóvenes en matemáticas, ciencias o idiomas. Modalidad presencial u online según disponibilidad.",
                category: "Educación"
            ),
            VolunteerSuggestion(
                title: "Campañas de reciclaje",
                description: "Organiza y promueve iniciativas de reciclaje en tu colonia o escuela. Educa sobre separación de residuos y economía circular.",
                category: "Ambiental"
            ),
            VolunteerSuggestion(
                title: "Apoyo en comedores comunitarios",
                description: "Colabora en la preparación y servicio de comidas para personas en situación de calle o escasos recursos.",
                category: "Comunitario"
            )
        ]
        
        // Seleccionar 5 sugerencias aleatorias
        let selectedSuggestions = suggestions.shuffled().prefix(5)
        
        print("✅ Generadas \(selectedSuggestions.count) sugerencias de voluntariado")
        return Array(selectedSuggestions)
    }
}

// MARK: - Production Service (Para futuro)
/// Estructura para cuando se conecte con IA real
final class ProductionVolunteerAIService: VolunteerAIServiceProtocol {
    private let baseURL = "https://api.tuservidor.com"
    
    func suggestVolunteerActivities(for profile: UserProfile?) async throws -> [VolunteerSuggestion] {
        // TODO: Implementar cuando se tenga backend con IA
        
        /*
        let url = URL(string: "\(baseURL)/api/volunteer/suggestions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["profile": profile]
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let suggestions = try JSONDecoder().decode([VolunteerSuggestion].self, from: data)
        
        return suggestions
        */
        
        // Por ahora, delegar al mock
        return try await MockVolunteerAIService.shared.suggestVolunteerActivities(for: profile)
    }
}
