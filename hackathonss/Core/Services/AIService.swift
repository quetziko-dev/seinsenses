import Foundation

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func analyzeEmotion(responses: [EmotionResponse], emotion: EmotionType, intensity: Double) async throws -> AIEmotionAnalysisResult
    func generateWellnessInsights(userProgress: PantherProgress) async throws -> [String]
    func suggestActivities(emotionalState: EmotionType) async throws -> [ActivitySuggestion]
}

// MARK: - Activity Suggestion Model
struct ActivitySuggestion: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: WellnessCategory
    let duration: Int // in minutes
    let difficulty: DifficultyLevel
    
    enum WellnessCategory: String, CaseIterable, Codable {
        case physical = "físico"
        case emotional = "emocional"
        case social = "social"
        case spiritual = "espiritual"
        case occupational = "ocupacional"
        case environmental = "ambiental"
    }
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case easy = "fácil"
        case medium = "medio"
        case hard = "difícil"
    }
}

// MARK: - AI Service Implementation
class AIService: AIServiceProtocol {
    static let shared = AIService()
    
    private init() {}
    
    func analyzeEmotion(responses: [EmotionResponse], emotion: EmotionType, intensity: Double) async throws -> AIEmotionAnalysisResult {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock AI analysis based on emotion and intensity
        return generateMockAnalysis(emotion: emotion, intensity: intensity, responses: responses)
    }
    
    func generateWellnessInsights(userProgress: PantherProgress) async throws -> [String] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        var insights: [String] = []
        
        // Level-based insights
        switch userProgress.currentLevel {
        case .cub:
            insights.append("¡Tu pantera está creciendo! Sigue así para desbloquear nuevas habilidades.")
            insights.append("Las actividades diarias son clave para el desarrollo de tu compañera.")
        case .young:
            insights.append("Tu pantera joven tiene mucha energía. Aprovecha para explorar nuevas actividades.")
            insights.append("Considera establecer metas más desafiantes en tu bienestar.")
        case .adult:
            insights.append("Tu pantera adulta es sabia y fuerte. Eres un maestro del bienestar.")
            insights.append("Comparte tu experiencia con otros para ayudarles en su viaje.")
        }
        
        // Streak-based insights
        if userProgress.consecutiveDays >= 7 {
            insights.append("¡Increíble racha de \(userProgress.consecutiveDays) días! La consistencia es tu superpoder.")
        } else if userProgress.consecutiveDays >= 3 {
            insights.append("Buena racha de \(userProgress.consecutiveDays) días. Mantén el impulso.")
        }
        
        // Experience-based insights
        if userProgress.experiencePoints >= userProgress.experienceToNextLevel - 20 {
            insights.append("¡Estás muy cerca del siguiente nivel! Solo faltan \(userProgress.experienceToNextLevel - userProgress.experiencePoints) puntos de experiencia.")
        }
        
        return insights
    }
    
    func suggestActivities(emotionalState: EmotionType) async throws -> [ActivitySuggestion] {
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        switch emotionalState {
        case .happy:
            return [
                ActivitySuggestion(
                    title: "Comparte tu alegría",
                    description: "Llama a un amigo o familiar para compartir tu buen estado de ánimo",
                    category: .social,
                    duration: 15,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Baile energético",
                    description: "Pon tu música favorita y baila por 10 minutos",
                    category: .physical,
                    duration: 10,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Diario de gratitud",
                    description: "Escribe 3 cosas por las que te sientes agradecido hoy",
                    category: .emotional,
                    duration: 5,
                    difficulty: .easy
                )
            ]
            
        case .sad:
            return [
                ActivitySuggestion(
                    title: "Caminata consciente",
                    description: "Una caminata de 20 minutos al aire libre para despejar tu mente",
                    category: .physical,
                    duration: 20,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Música sanadora",
                    description: "Escucha una playlist de música relajante o inspiradora",
                    category: .emotional,
                    duration: 15,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Habla con alguien",
                    description: "Contacta a un amigo de confianza para expresar cómo te sientes",
                    category: .social,
                    duration: 30,
                    difficulty: .medium
                )
            ]
            
        case .anxious:
            return [
                ActivitySuggestion(
                    title: "Respiración 4-7-8",
                    description: "Técnica de respiración para calmar la ansiedad rápidamente",
                    category: .emotional,
                    duration: 5,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Meditación guiada",
                    description: "Sesión de 10 minutos de meditación para reducir la ansiedad",
                    category: .spiritual,
                    duration: 10,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Ejercicio suave",
                    description: "Estiramientos o yoga suave para liberar tensión corporal",
                    category: .physical,
                    duration: 15,
                    difficulty: .easy
                )
            ]
            
        case .angry:
            return [
                ActivitySuggestion(
                    title: "Ejercicio intenso",
                    description: "Correr o hacer ejercicio vigoroso para canalizar la energía",
                    category: .physical,
                    duration: 20,
                    difficulty: .hard
                ),
                ActivitySuggestion(
                    title: "Escritura expresiva",
                    description: "Escribe sobre lo que te hace sentir enojado sin filtros",
                    category: .emotional,
                    duration: 15,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Técnica de enfriamiento",
                    description: "Toma agua fresca y concéntrate en sensaciones físicas calmantes",
                    category: .emotional,
                    duration: 10,
                    difficulty: .easy
                )
            ]
            
        case .grateful:
            return [
                ActivitySuggestion(
                    title: "Acto de bondad",
                    description: "Haz algo amable por otra persona sin esperar nada a cambio",
                    category: .social,
                    duration: 15,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Naturaleza consciente",
                    description: "Pasa tiempo en la naturaleza apreciando su belleza",
                    category: .environmental,
                    duration: 30,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Oración o meditación",
                    description: "Expresa tu gratitud a través de la oración o meditación",
                    category: .spiritual,
                    duration: 10,
                    difficulty: .easy
                )
            ]
            
        case .peaceful:
            return [
                ActivitySuggestion(
                    title: "Meditación profunda",
                    description: "Aprovecha tu estado de paz para una meditación más larga",
                    category: .spiritual,
                    duration: 20,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Lectura inspiradora",
                    description: "Lee un libro o texto que nutra tu espíritu",
                    category: .spiritual,
                    duration: 30,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Yoga o tai chi",
                    description: "Practica movimientos suaves que armonicen cuerpo y mente",
                    category: .physical,
                    duration: 25,
                    difficulty: .medium
                )
            ]
            
        case .stressed:
            return [
                ActivitySuggestion(
                    title: "Descanso digital",
                    description: "Desconecta de dispositivos electrónicos por 30 minutos",
                    category: .environmental,
                    duration: 30,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Organización del espacio",
                    description: "Ordena tu área de trabajo o habitación para reducir el estrés",
                    category: .environmental,
                    duration: 20,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Masaje autoaplicado",
                    description: "Realiza masajes suaves en cuello y hombros para liberar tensión",
                    category: .physical,
                    duration: 10,
                    difficulty: .easy
                )
            ]
            
        case .excited:
            return [
                ActivitySuggestion(
                    title: "Proyecto creativo",
                    description: "Canaliza tu energía en una actividad creativa que disfrutes",
                    category: .occupational,
                    duration: 45,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Aprende algo nuevo",
                    description: "Usa tu energía para aprender una nueva habilidad o conocimiento",
                    category: .occupational,
                    duration: 30,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Ejercicio divertido",
                    description: "Practica un deporte o actividad física que te entusiasme",
                    category: .physical,
                    duration: 30,
                    difficulty: .medium
                )
            ]
            
        case .tired:
            return [
                ActivitySuggestion(
                    title: "Siesta reparadora",
                    description: "Descansa 20 minutos para recargar energías",
                    category: .physical,
                    duration: 20,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Hidratación y nutrición",
                    description: "Bebe agua y come algo nutritivo para recuperar energía",
                    category: .physical,
                    duration: 15,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Estiramientos suaves",
                    description: "Realiza estiramientos suaves para revitalizar el cuerpo",
                    category: .physical,
                    duration: 10,
                    difficulty: .easy
                )
            ]
            
        case .confused:
            return [
                ActivitySuggestion(
                    title: "Escritura clarificadora",
                    description: "Escribe tus pensamientos para organizar tus ideas",
                    category: .emotional,
                    duration: 15,
                    difficulty: .easy
                ),
                ActivitySuggestion(
                    title: "Habla con alguien",
                    description: "Discute tus ideas con alguien de confianza para obtener perspectiva",
                    category: .social,
                    duration: 20,
                    difficulty: .medium
                ),
                ActivitySuggestion(
                    title: "Caminada meditativa",
                    description: "Camina mientras te concentras en respirar y aclarar tu mente",
                    category: .physical,
                    duration: 15,
                    difficulty: .easy
                )
            ]
        }
    }
    
    // MARK: - Private Helper Methods
    private func generateMockAnalysis(emotion: EmotionType, intensity: Double, responses: [EmotionResponse]) -> AIEmotionAnalysisResult {
        let responseCount = responses.count
        let avgResponseLength = responses.reduce(0) { $0 + $1.answer.count } / max(responseCount, 1)
        
        // Determine severity based on emotion type and intensity
        let severityLevel: AIEmotionAnalysisResult.SeverityLevel
        let isSevere: Bool
        
        switch emotion {
        case .happy, .grateful, .peaceful, .excited:
            severityLevel = .low
            isSevere = false
        case .sad, .tired, .confused:
            severityLevel = intensity > 0.7 ? .medium : .low
            isSevere = intensity > 0.8
        case .anxious, .stressed:
            severityLevel = intensity > 0.6 ? (intensity > 0.8 ? .high : .medium) : .low
            isSevere = intensity > 0.7
        case .angry:
            severityLevel = intensity > 0.5 ? (intensity > 0.8 ? .critical : .high) : .medium
            isSevere = intensity > 0.6
        }
        
        let summary = generateSummary(emotion: emotion, intensity: intensity, responseCount: responseCount)
        let suggestedAction = generateSuggestedAction(emotion: emotion, severityLevel: severityLevel)
        
        return AIEmotionAnalysisResult(
            isSevere: isSevere,
            severityLevel: severityLevel,
            summary: summary,
            suggestedAction: suggestedAction
        )
    }
    
    private func generateSummary(emotion: EmotionType, intensity: Double, responseCount: Int) -> String {
        let intensityDesc = intensity > 0.7 ? "muy intenso" : intensity > 0.4 ? "moderado" : "ligero"
        
        switch emotion {
        case .happy:
            return "Tu estado de ánimo es positivo y \(intensityDesc). Has proporcionado \(responseCount) respuestas reflexivas que indican buena autoconciencia emocional."
        case .sad:
            return "Detecté tristeza \(intensityDesc). Es normal sentirse así ocasionalmente. Tus respuestas muestran que estás procesando tus emociones de manera saludable."
        case .anxious:
            return "Niveles de ansiedad \(intensityDesc) detectados. Tus reflexiones sugieren preocupación activa. La autoconciencia que muestras es el primer paso para manejar esta sensación."
        case .angry:
            return "Enojo \(intensityDesc) identificado. Tus respuestas indican que estás intentando comprender esta emoción poderosa. Es importante encontrar formas constructivas de expresarla."
        case .grateful:
            return "Sentimientos de gratitud \(intensityDesc). Esta es una de las emociones más positivas para el bienestar mental. Tus reflexiones muestran una perspectiva apreciativa."
        case .peaceful:
            return "Estado de paz \(intensityDesc). Has alcanzado un equilibrio emocional saludable. Tus respuestas reflejan claridad mental y tranquilidad."
        case .stressed:
            return "Niveles de estrés \(intensityDesc) detectados. Tus respuestas sugieren múltiples presiones. La autoconciencia que demuestras es fundamental para manejar el estrés efectivamente."
        case .excited:
            return "Emoción de emoción \(intensityDesc). Esta energía positiva puede ser muy productiva. Tus reflexiones muestran entusiasmo y motivación."
        case .tired:
            return "Fatiga \(intensityDesc) identificada. Tus respuestas sugieren agotamiento físico o mental. Es importante priorizar el descanso y recuperación."
        case .confused:
            return "Confusión \(intensityDesc) detectada. Es normal sentirse así frente a situaciones complejas. Tus reflexiones muestran un intento activo de comprender tus pensamientos."
        }
    }
    
    private func generateSuggestedAction(emotion: EmotionType, severityLevel: AIEmotionAnalysisResult.SeverityLevel) -> String {
        switch (emotion, severityLevel) {
        case (.happy, _):
            return "Aprovecha esta energía positiva para compartir tu alegría con otros o iniciar proyectos que te motiven."
        case (.sad, .low):
            return "Considera actividades suaves como caminar al aire libre o hablar con un amigo de confianza."
        case (.sad, .medium):
            return "Practica autocuidado intencional y considera escribir sobre tus sentimientos. No dudes en buscar apoyo si persiste."
        case (.sad, .high), (.sad, .critical):
            return "Es importante buscar apoyo profesional. Habla con un terapeuta o consejero sobre tus sentimientos."
            
        case (.anxious, .low):
            return "Practica técnicas de respiración y mindfulness. La actividad física suave puede ayudar a reducir la ansiedad."
        case (.anxious, .medium):
            return "Establece una rutina de ejercicios de relajación y considera limitar la exposición a factores estresantes."
        case (.anxious, .high), (.anxious, .critical):
            return "Busca apoyo profesional inmediatamente. La terapia cognitivo-conductual puede ser muy efectiva para la ansiedad."
            
        case (.angry, .low):
            return "Canaliza esta energía a través del ejercicio físico o actividades creativas."
        case (.angry, .medium):
            return "Practica técnicas de enfriamiento y considera hablar sobre lo que te molesta con alguien de confianza."
        case (.angry, .high), (.angry, .critical):
            return "Busca ayuda profesional para manejar el enojo de manera constructiva. Considera clases de manejo de la ira."
            
        case (.grateful, _):
            return "Comparte tu gratitud con otros y considera llevar un diario diario de agradecimiento."
            
        case (.peaceful, _):
            return "Aprovecha este estado para meditación profunda o actividades que requieran concentración y creatividad."
            
        case (.stressed, .low):
            return "Implementa pausas regulares durante el día y practica técnicas de relajación rápida."
        case (.stressed, .medium):
            return "Revisa tus prioridades y delega tareas cuando sea posible. Establece límites claros trabajo-vida."
        case (.stressed, .high), (.stressed, .critical):
            return "Considera tomar un descanso significativo y busca apoyo profesional para manejar el estrés crónico."
            
        case (.excited, _):
            return "Canaliza esta energía en proyectos significativos o actividades que te apasionen."
            
        case (.tired, _):
            return "Prioriza el descanso adecuado y establece una rutina de sueño saludable. Considera reducir compromisos temporariamente."
            
        case (.confused, .low):
            return "Tómate tiempo para organizar tus pensamientos mediante la escritura o hablar con alguien de confianza."
        case (.confused, .medium):
            return "Divide los problemas complejos en partes más pequeñas y abórdalos uno por uno."
        case (.confused, .high), (.confused, .critical):
            return "Busca orientación de un mentor o profesional que pueda ayudarte a clarificar tu situación."
        }
    }
}
