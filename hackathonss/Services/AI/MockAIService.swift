import Foundation

// MARK: - Mock AI Service for Testing
class MockAIService: AIServiceProtocol {
    
    // MARK: - Configuration
    private let simulateDelay: Bool
    private let shouldFail: Bool
    private let failureRate: Double
    
    init(simulateDelay: Bool = false, shouldFail: Bool = false, failureRate: Double = 0.0) {
        self.simulateDelay = simulateDelay
        self.shouldFail = shouldFail
        self.failureRate = failureRate
    }
    
    // MARK: - AIServiceProtocol Implementation
    func analyzeEmotion(responses: [EmotionResponse], emotion: EmotionType, intensity: Double) async throws -> AIEmotionAnalysisResult {
        if simulateDelay {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        if shouldFail || Double.random(in: 0...1) < failureRate {
            throw AIServiceError.analysisFailed
        }
        
        return generateMockAnalysis(emotion: emotion, intensity: intensity, responses: responses)
    }
    
    func generateWellnessInsights(userProgress: PantherProgress) async throws -> [String] {
        if simulateDelay {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        }
        
        if shouldFail || Double.random(in: 0...1) < failureRate {
            throw AIServiceError.insightGenerationFailed
        }
        
        return generateMockInsights(userProgress: userProgress)
    }
    
    func suggestActivities(emotionalState: EmotionType) async throws -> [ActivitySuggestion] {
        if simulateDelay {
            try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        }
        
        if shouldFail || Double.random(in: 0...1) < failureRate {
            throw AIServiceError.suggestionFailed
        }
        
        return generateMockSuggestions(emotion: emotionalState)
    }
    
    // MARK: - Mock Data Generation
    private func generateMockAnalysis(emotion: EmotionType, intensity: Double, responses: [EmotionResponse]) -> AIEmotionAnalysisResult {
        let severityLevel = determineSeverity(emotion: emotion, intensity: intensity)
        let isSevere = severityLevel == .high || severityLevel == .critical
        
        let summary = generateMockSummary(emotion: emotion, intensity: intensity, responseCount: responses.count)
        let suggestedAction = generateMockSuggestedAction(emotion: emotion, severityLevel: severityLevel)
        
        return AIEmotionAnalysisResult(
            isSevere: isSevere,
            severityLevel: severityLevel,
            summary: summary,
            suggestedAction: suggestedAction
        )
    }
    
    private func generateMockInsights(userProgress: PantherProgress) -> [String] {
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
    
    private func generateMockSuggestions(emotion: EmotionType) -> [ActivitySuggestion] {
        switch emotion {
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
                )
            ]
        }
    }
    
    // MARK: - Helper Methods
    private func determineSeverity(emotion: EmotionType, intensity: Double) -> AIEmotionAnalysisResult.SeverityLevel {
        switch emotion {
        case .happy, .grateful, .peaceful, .excited:
            return .low
            
        case .sad, .tired, .confused:
            return intensity > 0.7 ? .medium : .low
            
        case .anxious, .stressed:
            return intensity > 0.6 ? (intensity > 0.8 ? .high : .medium) : .low
            
        case .angry:
            return intensity > 0.5 ? (intensity > 0.8 ? .critical : .high) : .medium
        }
    }
    
    private func generateMockSummary(emotion: EmotionType, intensity: Double, responseCount: Int) -> String {
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
    
    private func generateMockSuggestedAction(emotion: EmotionType, severityLevel: AIEmotionAnalysisResult.SeverityLevel) -> String {
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
            return "Prioriza el descanso adecuado y establece una rutina de sueño saludable. Considera reducir compromisos temporalmente."
            
        case (.confused, .low):
            return "Tómate tiempo para organizar tus pensamientos mediante la escritura o hablar con alguien de confianza."
        case (.confused, .medium):
            return "Divide los problemas complejos en partes más pequeñas y abórdalos uno por uno."
        case (.confused, .high), (.confused, .critical):
            return "Busca orientación de un mentor o profesional que pueda ayudarte a clarificar tu situación."
        }
    }
}

// MARK: - Mock AI Service Error
enum AIServiceError: Error, LocalizedError {
    case analysisFailed
    case insightGenerationFailed
    case suggestionFailed
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .analysisFailed:
            return "Error al analizar la emoción (Mock)"
        case .insightGenerationFailed:
            return "Error al generar insights (Mock)"
        case .suggestionFailed:
            return "Error al generar sugerencias (Mock)"
        case .networkError:
            return "Error de red (Mock)"
        case .invalidResponse:
            return "Respuesta inválida (Mock)"
        }
    }
}

// MARK: - Mock AI Service Factory
class MockAIServiceFactory {
    static func createService(for scenario: MockScenario) -> MockAIService {
        switch scenario {
        case .perfect:
            return MockAIService(simulateDelay: false, shouldFail: false, failureRate: 0.0)
        case .realistic:
            return MockAIService(simulateDelay: true, shouldFail: false, failureRate: 0.0)
        case .unreliable:
            return MockAIService(simulateDelay: true, shouldFail: false, failureRate: 0.2)
        case .failing:
            return MockAIService(simulateDelay: true, shouldFail: true, failureRate: 1.0)
        }
    }
    
    enum MockScenario {
        case perfect      // Always succeeds, no delay
        case realistic    // Succeeds with realistic delay
        case unreliable   // 20% failure rate with delay
        case failing      // Always fails with delay
    }
}

// MARK: - Test Data Generator
extension MockAIService {
    static func generateTestData() -> (responses: [EmotionResponse], emotion: EmotionType, intensity: Double) {
        let responses = [
            EmotionResponse(
                question: "¿Cómo te sientes hoy?",
                answer: "Me siento bastante bien en general, aunque un poco cansado."
            ),
            EmotionResponse(
                question: "¿Qué ha influido en tu estado de ánimo?",
                answer: "El buen tiempo y haber dormido bien han ayudado mucho."
            ),
            EmotionResponse(
                question: "¿Qué puedes hacer para mantenerte así?",
                answer: "Continuar con mi rutina de ejercicio y meditación."
            ),
            EmotionResponse(
                question: "¿Necesitas apoyo en algo específico?",
                answer: "No realmente, me siento bastante equilibrado ahora mismo."
            )
        ]
        
        return (responses: responses, emotion: .happy, intensity: 0.7)
    }
    
    static func generateStressTestData() -> (responses: [EmotionResponse], emotion: EmotionType, intensity: Double) {
        let responses = [
            EmotionResponse(
                question: "¿Cómo te sientes hoy?",
                answer: "Me siento muy abrumado y estresado por el trabajo."
            ),
            EmotionResponse(
                question: "¿Qué ha influido en tu estado de ánimo?",
                answer: "Tengo muchos plazos y presión constante en la oficina."
            ),
            EmotionResponse(
                question: "¿Qué puedes hacer para manejar esto?",
                answer: "Necesito organizar mejor mi tiempo y aprender a decir no."
            ),
            EmotionResponse(
                question: "¿Necesitas apoyo en algo específico?",
                answer: "Sí, necesito ayuda para gestionar el estrés y encontrar equilibrio."
            )
        ]
        
        return (responses: responses, emotion: .stressed, intensity: 0.8)
    }
}
