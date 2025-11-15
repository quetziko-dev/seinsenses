import Foundation

// MARK: - Emotional AI Service Protocol
protocol EmotionalAIServiceProtocol {
    func analyze(answers: [ReflectiveAnswer]) async throws -> IAEmotionAnalysisResult
}

// MARK: - Reflective Answer Model
struct ReflectiveAnswer: Identifiable, Codable {
    let id: UUID
    let question: String
    let answer: String
    
    init(question: String, answer: String) {
        self.id = UUID()
        self.question = question
        self.answer = answer
    }
}

// MARK: - IA Emotion Analysis Result
struct IAEmotionAnalysisResult: Identifiable, Codable {
    let id: UUID
    let isSevere: Bool
    let severityLevel: SeverityLevel
    let summary: String
    let suggestedActions: [String]
    let emotionalState: String
    let createdAt: Date
    
    enum SeverityLevel: String, Codable {
        case low = "bajo"
        case moderate = "moderado"
        case high = "alto"
        case critical = "crítico"
        
        var color: String {
            switch self {
            case .low: return "#4CAF50"        // Verde
            case .moderate: return "#FFC107"   // Amarillo
            case .high: return "#FF9800"       // Naranja
            case .critical: return "#F44336"   // Rojo
            }
        }
        
        var emoji: String {
            switch self {
            case .low: return "😊"
            case .moderate: return "😐"
            case .high: return "😟"
            case .critical: return "😰"
            }
        }
    }
    
    init(isSevere: Bool, severityLevel: SeverityLevel, summary: String, suggestedActions: [String], emotionalState: String) {
        self.id = UUID()
        self.isSevere = isSevere
        self.severityLevel = severityLevel
        self.summary = summary
        self.suggestedActions = suggestedActions
        self.emotionalState = emotionalState
        self.createdAt = Date()
    }
}

// MARK: - Mock Implementation
/// Servicio de análisis emocional con IA
///
/// ⚠️ DISCLAIMER IMPORTANTE:
/// Este análisis es una herramienta de APOYO y REFLEXIÓN personal
/// NO es un diagnóstico médico ni psicológico
/// NO sustituye la atención de profesionales de salud mental
/// Si te sientes muy mal o en riesgo, busca ayuda profesional inmediatamente
///
/// 🔮 FUTURO - Integración con IA Real:
/// Para conectar con OpenAI u otra API:
/// 1. Crear backend que maneje API keys de forma segura
/// 2. Enviar las respuestas del usuario al backend
/// 3. Backend procesa con IA y devuelve análisis
/// 4. NUNCA exponer API keys en la app
@MainActor
final class MockEmotionalAIService: EmotionalAIServiceProtocol {
    static let shared = MockEmotionalAIService()
    
    private init() {}
    
    func analyze(answers: [ReflectiveAnswer]) async throws -> IAEmotionAnalysisResult {
        // Simular latencia de red
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
        
        // Analizar respuestas
        let analysis = performAnalysis(answers: answers)
        
        print("✅ Análisis emocional completado: \(analysis.emotionalState)")
        return analysis
    }
    
    private func performAnalysis(answers: [ReflectiveAnswer]) -> IAEmotionAnalysisResult {
        // Palabras clave para detectar estados emocionales
        let negativeKeywords = [
            "triste", "deprimido", "solo", "ansiedad", "preocupado", "estresado",
            "agotado", "cansado", "mal", "terrible", "horrible", "angustiado",
            "miedo", "pánico", "vacío", "desesperado", "abrumado", "perdido"
        ]
        
        let positiveKeywords = [
            "feliz", "contento", "bien", "excelente", "alegre", "motivado",
            "energético", "positivo", "tranquilo", "relajado", "satisfecho",
            "optimista", "esperanzado", "agradecido", "emocionado"
        ]
        
        // Combinar todas las respuestas
        let allText = answers.map { $0.answer.lowercased() }.joined(separator: " ")
        
        // Contar palabras negativas y positivas
        var negativeCount = 0
        var positiveCount = 0
        
        for keyword in negativeKeywords {
            if allText.contains(keyword) {
                negativeCount += 1
            }
        }
        
        for keyword in positiveKeywords {
            if allText.contains(keyword) {
                positiveCount += 1
            }
        }
        
        // Analizar longitud de respuestas (respuestas muy cortas pueden indicar apatía)
        let avgLength = answers.map { $0.answer.count }.reduce(0, +) / max(answers.count, 1)
        let isEngaged = avgLength > 20
        
        // Determinar severidad y estado
        let severityLevel: IAEmotionAnalysisResult.SeverityLevel
        let isSevere: Bool
        let emotionalState: String
        let summary: String
        let suggestedActions: [String]
        
        if negativeCount > 5 || (negativeCount > 3 && !isEngaged) {
            severityLevel = .critical
            isSevere = true
            emotionalState = "Momento difícil"
            summary = "Parece que estás atravesando un momento emocionalmente desafiante. Tus respuestas reflejan sentimientos de malestar significativo. Es importante que sepas que está bien no estar bien, y que pedir ayuda es un acto de valentía y autocuidado."
            suggestedActions = [
                "Considera hablar con un profesional de salud mental",
                "Contacta a alguien de confianza para compartir cómo te sientes",
                "Practica técnicas de respiración para reducir la ansiedad",
                "Establece una rutina diaria simple y alcanzable",
                "Evita tomar decisiones importantes en este momento",
                "Si tienes pensamientos de hacerte daño, busca ayuda inmediata"
            ]
        } else if negativeCount > 2 || (negativeCount > 0 && positiveCount == 0) {
            severityLevel = .high
            isSevere = true
            emotionalState = "Algo estresado/a"
            summary = "Detectamos que podrías estar experimentando algo de estrés o preocupación. Aunque es normal tener altibajos, es importante cuidar tu bienestar emocional antes de que el malestar se intensifique."
            suggestedActions = [
                "Identifica las fuentes de estrés en tu vida",
                "Dedica tiempo diario para actividades que disfrutes",
                "Mantén una rutina de sueño regular",
                "Practica ejercicios de relajación o meditación",
                "Habla con amigos o familia sobre cómo te sientes",
                "Considera escribir en tu diario emocional regularmente"
            ]
        } else if negativeCount > 0 || positiveCount < 2 {
            severityLevel = .moderate
            isSevere = false
            emotionalState = "Estado mixto"
            summary = "Tus respuestas muestran un balance entre momentos positivos y algunos desafíos. Esto es completamente normal y humano. Estás en un punto donde puedes fortalecer tu bienestar con pequeñas acciones diarias."
            suggestedActions = [
                "Continúa con las prácticas que te hacen sentir bien",
                "Identifica y limita actividades que te drenan energía",
                "Establece límites saludables en tus relaciones",
                "Practica gratitud diariamente",
                "Mantén conexiones sociales significativas",
                "Cuida tu rutina de sueño y alimentación"
            ]
        } else {
            severityLevel = .low
            isSevere = false
            emotionalState = "Estado positivo"
            summary = "Tus respuestas reflejan un estado emocional positivo y saludable. Estás manejando bien tus emociones y mantienes una perspectiva constructiva. Sigue fortaleciendo estos hábitos que te hacen sentir bien."
            suggestedActions = [
                "Continúa con tus prácticas de autocuidado actuales",
                "Comparte tu energía positiva con otros",
                "Establece nuevas metas personales",
                "Practica la gratitud regularmente",
                "Mantén tus conexiones sociales",
                "Explora nuevas actividades que te interesen"
            ]
        }
        
        return IAEmotionAnalysisResult(
            isSevere: isSevere,
            severityLevel: severityLevel,
            summary: summary,
            suggestedActions: suggestedActions,
            emotionalState: emotionalState
        )
    }
}

// MARK: - Production Service (Para futuro)
/// Estructura para cuando se conecte con IA real
final class ProductionEmotionalAIService: EmotionalAIServiceProtocol {
    private let baseURL = "https://api.tuservidor.com"
    
    func analyze(answers: [ReflectiveAnswer]) async throws -> IAEmotionAnalysisResult {
        // TODO: Implementar cuando se tenga backend con IA
        
        /*
        let url = URL(string: "\(baseURL)/api/emotional-analysis")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["answers": answers]
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(IAEmotionAnalysisResult.self, from: data)
        
        return result
        */
        
        // Por ahora, delegar al mock
        return try await MockEmotionalAIService.shared.analyze(answers: answers)
    }
}
