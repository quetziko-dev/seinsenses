import Foundation

// MARK: - AI Emotion Analyzer Protocol
protocol AIEmotionAnalyzerProtocol {
    func analyzeEmotion(
        emotion: EmotionType,
        intensity: Double,
        responses: [EmotionResponse],
        context: EmotionAnalysisContext?
    ) async throws -> AIEmotionAnalysisResult
    func generatePersonalizedInsights(userHistory: [EmotionData]) async throws -> [EmotionalInsight]
    func predictEmotionalTrend(emotionHistory: [EmotionData]) async throws -> EmotionalTrend
}

// MARK: - Emotion Analysis Context
struct EmotionAnalysisContext: Codable {
    let timeOfDay: TimeOfDay
    let dayOfWeek: String
    let weatherCondition: WeatherCondition?
    let recentActivities: [String]
    let sleepQuality: SleepQuality?
    let stressLevel: StressLevel?
    
    enum TimeOfDay: String, CaseIterable, Codable {
        case morning = "mañana"
        case afternoon = "tarde"
        case evening = "noche"
        case night = "noche tardía"
    }
    
    enum WeatherCondition: String, CaseIterable, Codable {
        case sunny = "soleado"
        case cloudy = "nublado"
        case rainy = "lluvioso"
        case cold = "frío"
        case hot = "caluroso"
    }
    
    enum StressLevel: String, CaseIterable, Codable {
        case low = "bajo"
        case medium = "medio"
        case high = "alto"
        case veryHigh = "muy alto"
    }
}

// MARK: - Emotional Insight
struct EmotionalInsight: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: InsightCategory
    let severity: InsightSeverity
    let actionableSteps: [String]
    let relatedEmotions: [EmotionType]
    
    enum InsightCategory: String, CaseIterable, Codable {
        case pattern = "patrón"
        case trigger = "desencadenante"
        case coping = "afrontamiento"
        case improvement = "mejora"
        case warning = "advertencia"
    }
    
    enum InsightSeverity: String, CaseIterable, Codable {
        case informational = "informativo"
        case suggestion = "sugerencia"
        case recommendation = "recomendación"
        case alert = "alerta"
    }
}

// MARK: - Emotional Trend
struct EmotionalTrend: Codable {
    let trendDirection: TrendDirection
    let confidence: Double // 0.0 to 1.0
    let predictedEmotions: [EmotionPrediction]
    let timeframe: TrendTimeframe
    let factors: [TrendFactor]
    
    enum TrendDirection: String, CaseIterable, Codable {
        case improving = "mejorando"
        case declining = "declinando"
        case stable = "estable"
        case fluctuating = "fluctuando"
    }
    
    enum TrendTimeframe: String, CaseIterable, Codable {
        case daily = "diario"
        case weekly = "semanal"
        case monthly = "mensual"
    }
    
    struct EmotionPrediction: Codable {
        let emotion: EmotionType
        let probability: Double // 0.0 to 1.0
        let timeframe: String
    }
    
    struct TrendFactor: Codable {
        let name: String
        let impact: Double // -1.0 to 1.0
        let description: String
    }
}

// MARK: - AI Emotion Analyzer Implementation
class AIEmotionAnalyzer: AIEmotionAnalyzerProtocol {
    static let shared = AIEmotionAnalyzer()
    
    private init() {}
    
    func analyzeEmotion(
        emotion: EmotionType,
        intensity: Double,
        responses: [EmotionResponse],
        context: EmotionAnalysisContext?
    ) async throws -> AIEmotionAnalysisResult {
        // Simulate AI processing time
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Generate comprehensive analysis
        let analysis = await generateComprehensiveAnalysis(
            emotion: emotion,
            intensity: intensity,
            responses: responses,
            context: context
        )
        
        return analysis
    }
    
    func generatePersonalizedInsights(userHistory: [EmotionData]) async throws -> [EmotionalInsight] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        var insights: [EmotionalInsight] = []
        
        // Analyze patterns
        insights.append(contentsOf: analyzeEmotionalPatterns(userHistory))
        
        // Identify triggers
        insights.append(contentsOf: identifyEmotionalTriggers(userHistory))
        
        // Suggest coping mechanisms
        insights.append(contentsOf: suggestCopingMechanisms(userHistory))
        
        // Generate improvement suggestions
        insights.append(contentsOf: generateImprovementSuggestions(userHistory))
        
        // Check for warning signs
        insights.append(contentsOf: checkWarningSigns(userHistory))
        
        return insights.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }
    
    func predictEmotionalTrend(emotionHistory: [EmotionData]) async throws -> EmotionalTrend {
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        guard emotionHistory.count >= 3 else {
            return EmotionalTrend(
                trendDirection: .stable,
                confidence: 0.0,
                predictedEmotions: [],
                timeframe: .weekly,
                factors: []
            )
        }
        
        let recentEmotions = Array(emotionHistory.suffix(7))
        let trendDirection = calculateTrendDirection(recentEmotions)
        let confidence = calculateTrendConfidence(recentEmotions)
        let predictions = generateEmotionPredictions(recentEmotions)
        let factors = identifyTrendFactors(recentEmotions)
        
        return EmotionalTrend(
            trendDirection: trendDirection,
            confidence: confidence,
            predictedEmotions: predictions,
            timeframe: .weekly,
            factors: factors
        )
    }
    
    // MARK: - Private Analysis Methods
    private func generateComprehensiveAnalysis(
        emotion: EmotionType,
        intensity: Double,
        responses: [EmotionResponse],
        context: EmotionAnalysisContext?
    ) async -> AIEmotionAnalysisResult {
        
        // Base severity from emotion type and intensity
        let baseSeverity = determineBaseSeverity(emotion: emotion, intensity: intensity)
        
        // Context adjustments
        let adjustedSeverity = adjustSeverityForContext(baseSeverity, context: context)
        
        // Response analysis
        let responseInsights = analyzeResponseContent(responses)
        
        // Generate summary
        let summary = generateAnalysisSummary(
            emotion: emotion,
            intensity: intensity,
            severity: adjustedSeverity,
            context: context,
            responseInsights: responseInsights
        )
        
        // Generate suggested action
        let suggestedAction = generateSuggestedAction(
            emotion: emotion,
            severity: adjustedSeverity,
            context: context,
            responseInsights: responseInsights
        )
        
        let isSevere = adjustedSeverity == .high || adjustedSeverity == .critical
        
        return AIEmotionAnalysisResult(
            isSevere: isSevere,
            severityLevel: adjustedSeverity,
            summary: summary,
            suggestedAction: suggestedAction
        )
    }
    
    private func determineBaseSeverity(emotion: EmotionType, intensity: Double) -> AIEmotionAnalysisResult.SeverityLevel {
        switch emotion {
        case .happy, .grateful, .peaceful, .excited:
            return .low
            
        case .sad, .tired, .confused:
            if intensity > 0.8 {
                return .medium
            } else if intensity > 0.6 {
                return .low
            } else {
                return .low
            }
            
        case .anxious, .stressed:
            if intensity > 0.8 {
                return .high
            } else if intensity > 0.5 {
                return .medium
            } else {
                return .low
            }
            
        case .angry:
            if intensity > 0.8 {
                return .critical
            } else if intensity > 0.6 {
                return .high
            } else if intensity > 0.3 {
                return .medium
            } else {
                return .low
            }
        }
    }
    
    private func adjustSeverityForContext(
        _ severity: AIEmotionAnalysisResult.SeverityLevel,
        context: EmotionAnalysisContext?
    ) -> AIEmotionAnalysisResult.SeverityLevel {
        
        guard let context = context else { return severity }
        
        var adjustedSeverity = severity
        
        // Time-based adjustments
        switch context.timeOfDay {
        case .night:
            if severity == .medium {
                adjustedSeverity = .high
            }
        case .morning:
            if severity == .high {
                adjustedSeverity = .medium
            }
        default:
            break
        }
        
        // Stress level adjustments
        if let stressLevel = context.stressLevel {
            switch stressLevel {
            case .veryHigh:
                if adjustedSeverity == .medium {
                    adjustedSeverity = .high
                } else if adjustedSeverity == .high {
                    adjustedSeverity = .critical
                }
            case .low:
                if adjustedSeverity == .high && severity != .critical {
                    adjustedSeverity = .medium
                }
            default:
                break
            }
        }
        
        // Sleep quality adjustments
        if let sleepQuality = context.sleepQuality {
            if sleepQuality == .poor && adjustedSeverity == .low {
                adjustedSeverity = .medium
            }
        }
        
        return adjustedSeverity
    }
    
    private func analyzeResponseContent(_ responses: [EmotionResponse]) -> ResponseInsights {
        let totalResponses = responses.count
        let avgResponseLength = responses.reduce(0) { $0 + $1.answer.count } / max(totalResponses, 1)
        
        // Analyze keywords
        let allText = responses.map { $0.answer.lowercased() }.joined(separator: " ")
        
        let negativeKeywords = ["triste", "malo", "terrible", "odio", "miedo", "ansiedad", "estrés", "enojo"]
        let positiveKeywords = ["feliz", "bien", "bueno", "amor", "paz", "calma", "alegría", "gratitud"]
        let helpKeywords = ["ayuda", "necesito", "no puedo", "difícil", "duro", "imposible"]
        
        let negativeCount = negativeKeywords.filter { allText.contains($0) }.count
        let positiveCount = positiveKeywords.filter { allText.contains($0) }.count
        let helpCount = helpKeywords.filter { allText.contains($0) }.count
        
        return ResponseInsights(
            totalResponses: totalResponses,
            averageLength: avgResponseLength,
            negativeKeywordCount: negativeCount,
            positiveKeywordCount: positiveCount,
            helpSeekingCount: helpCount,
            isDetailed: avgResponseLength > 50
        )
    }
    
    private func generateAnalysisSummary(
        emotion: EmotionType,
        intensity: Double,
        severity: AIEmotionAnalysisResult.SeverityLevel,
        context: EmotionAnalysisContext?,
        responseInsights: ResponseInsights
    ) -> String {
        
        let intensityDesc = describeIntensity(intensity)
        let emotionDesc = describeEmotion(emotion)
        
        var summary = "Tu estado emocional actual es \(emotionDesc) con una intensidad \(intensityDesc)."
        
        // Add context information
        if let context = context {
            summary += " " + generateContextSummary(context)
        }
        
        // Add response insights
        if responseInsights.isDetailed {
            summary += " Tus respuestas reflexivas muestran una profunda autoconciencia emocional."
        } else if responseInsights.helpSeekingCount > 0 {
            summary += " He notado que buscas activamente formas de manejar tus emociones."
        }
        
        // Add severity context
        switch severity {
        case .critical:
            summary += " Este nivel de intensidad requiere atención inmediata."
        case .high:
            summary += " Es importante abordar estos sentimientos con cuidado y apoyo."
        case .medium:
            summary += " Considera implementar estrategias de manejo emocional."
        case .low:
            summary += " Este estado emocional es manejable y normal."
        }
        
        return summary
    }
    
    private func generateSuggestedAction(
        emotion: EmotionType,
        severity: AIEmotionAnalysisResult.SeverityLevel,
        context: EmotionAnalysisContext?,
        responseInsights: ResponseInsights
    ) -> String {
        
        switch (emotion, severity) {
        case (.happy, _):
            return "Aprovecha esta energía positiva compartiendo tu alegría con otros o iniciando proyectos que te motiven."
            
        case (.sad, .low):
            return "Considera actividades suaves como caminar al aire libre, escuchar música uplifting o hablar con un amigo de confianza."
        case (.sad, .medium):
            return "Practica autocuidado intencional: escribe sobre tus sentimientos, establece pequeñas metas alcanzables y no dudes en buscar apoyo."
        case (.sad, .high), (.sad, .critical):
            return "Es importante buscar apoyo profesional. Habla con un terapeuta o consejero sobre tus sentimientos de tristeza."
            
        case (.anxious, .low):
            return "Practica técnicas de respiración 4-7-8, mindfulness o actividad física suave como yoga o caminata."
        case (.anxious, .medium):
            return "Establece una rutina de ejercicios de relajación, limita la cafeína y considera técnicas de grounding cuando sientas ansiedad."
        case (.anxious, .high), (.anxious, .critical):
            return "Busca apoyo profesional inmediatamente. La terapia cognitivo-conductual y técnicas de exposición gradual pueden ser muy efectivas."
            
        case (.angry, .low):
            return "Canaliza esta energía a través del ejercicio físico intenso, escritura expresiva o actividades creativas."
        case (.angry, .medium):
            return "Practica técnicas de enfriamiento: cuenta hasta 10, respira profundamente y considera hablar sobre lo que te molesta."
        case (.angry, .high), (.angry, .critical):
            return "Busca ayuda profesional para manejar el enojo de manera constructiva. Considera clases de manejo de la ira o terapia especializada."
            
        case (.grateful, _):
            return "Comparte tu gratitud con otros, lleva un diario de agradecimiento o realiza actos de bondad."
            
        case (.peaceful, _):
            return "Aprovecha este estado para meditación profunda, lectura inspiradora o actividades que requieran concentración."
            
        case (.stressed, .low):
            return "Implementa micro-pausas durante el día, practica estiramientos y asegúrate de mantenerte hidratado."
        case (.stressed, .medium):
            return "Revisa tus prioridades, delega tareas cuando sea posible y establece límites claros trabajo-vida."
        case (.stressed, .high), (.stressed, .critical):
            return "Considera tomar un descanso significativo, busca apoyo profesional y evalúa seriamente tu carga de responsabilidades."
            
        case (.excited, _):
            return "Canaliza esta energía en proyectos significativos, aprendizaje de nuevas habilidades o actividades físicas."
            
        case (.tired, _):
            return "Prioriza el descanso adecuado, establece una rutina de sueño saludable y considera reducir compromisos temporalmente."
            
        case (.confused, .low):
            return "Tómate tiempo para organizar tus pensamientos mediante la escritura o hablar con alguien de confianza."
        case (.confused, .medium):
            return "Divide los problemas complejos en partes más pequeñas y abórdalos uno por uno con enfoque y paciencia."
        case (.confused, .high), (.confused, .critical):
            return "Busca orientación de un mentor, coach o profesional que pueda ayudarte a clarificar tu situación y encontrar dirección."
        }
    }
    
    // MARK: - Insight Generation Methods
    private func analyzeEmotionalPatterns(_ history: [EmotionData]) -> [EmotionalInsight] {
        var insights: [EmotionalInsight] = []
        
        // Time-based patterns
        let timePatterns = analyzeTimePatterns(history)
        insights.append(contentsOf: timePatterns)
        
        // Intensity patterns
        let intensityPatterns = analyzeIntensityPatterns(history)
        insights.append(contentsOf: intensityPatterns)
        
        return insights
    }
    
    private func identifyEmotionalTriggers(_ history: [EmotionData]) -> [EmotionalInsight] {
        var insights: [EmotionalInsight] = []
        
        // Common triggers based on responses
        let triggerInsight = EmotionalInsight(
            title: "Patrones de Desencadenantes",
            description: "He identificado patrones en tus respuestas que sugieren ciertos desencadenantes emocionales comunes.",
            category: .trigger,
            severity: .suggestion,
            actionableSteps: [
                "Lleva un registro de situaciones antes de emociones intensas",
                "Practica mindfulness para identificar desencadenantes en tiempo real",
                "Desarrolla estrategias de afrontamiento específicas para cada desencadenante"
            ],
            relatedEmotions: [.anxious, .stressed, .angry]
        )
        
        insights.append(triggerInsight)
        return insights
    }
    
    private func suggestCopingMechanisms(_ history: [EmotionData]) -> [EmotionalInsight] {
        let copingInsight = EmotionalInsight(
            title: "Estrategias de Afrontamiento Personalizadas",
            description: "Basado en tu historial emocional, estas estrategias podrían ser particularmente efectivas para ti.",
            category: .coping,
            severity: .recommendation,
            actionableSteps: [
                "Practica respiración profunda por 5 minutos diariamente",
                "Establece una rutina de ejercicio moderado 3 veces por semana",
                "Dedica 10 minutos cada noche para reflexionar sobre tu día"
            ],
            relatedEmotions: EmotionType.allCases
        )
        
        return [copingInsight]
    }
    
    private func generateImprovementSuggestions(_ history: [EmotionData]) -> [EmotionalInsight] {
        let improvementInsight = EmotionalInsight(
            title: "Oportunidades de Crecimiento Emocional",
            description: "He identificado áreas donde podrías fortalecer tu inteligencia emocional.",
            category: .improvement,
            severity: .suggestion,
            actionableSteps: [
                "Explora nuevas técnicas de mindfulness",
                "Considera unirte a un grupo de apoyo o comunidad",
                "Practica la expresión emocional saludable regularmente"
            ],
            relatedEmotions: [.happy, .grateful, .peaceful]
        )
        
        return [improvementInsight]
    }
    
    private func checkWarningSigns(_ history: [EmotionData]) -> [EmotionalInsight] {
        var insights: [EmotionalInsight] = []
        
        // Check for concerning patterns
        let recentNegativeEmotions = history.suffix(7).filter { 
            [.sad, .anxious, .angry, .stressed].contains($0.emotion) 
        }
        
        if recentNegativeEmotions.count >= 5 {
            let warningInsight = EmotionalInsight(
                title: "Patrón Emocional Preocupante",
                description: "He notado un patrón reciente de emociones negativas que podría beneficiarse de atención adicional.",
                category: .warning,
                severity: .alert,
                actionableSteps: [
                    "Considera hablar con un profesional de salud mental",
                    "Aumenta las actividades de autocuidado",
                    "Busca apoyo de amigos y familiares",
                    "Monitorea tus patrones de sueño y nutrición"
                ],
                relatedEmotions: [.sad, .anxious, .angry, .stressed]
            )
            
            insights.append(warningInsight)
        }
        
        return insights
    }
    
    // MARK: - Helper Methods
    private func describeIntensity(_ intensity: Double) -> String {
        switch intensity {
        case 0.0..<0.2: return "muy ligera"
        case 0.2..<0.4: return "ligera"
        case 0.4..<0.6: return "moderada"
        case 0.6..<0.8: return "intensa"
        default: return "muy intensa"
        }
    }
    
    private func describeEmotion(_ emotion: EmotionType) -> String {
        switch emotion {
        case .happy: return "felicidad"
        case .sad: return "tristeza"
        case .anxious: return "ansiedad"
        case .angry: return "enojo"
        case .grateful: return "gratitud"
        case .peaceful: return "paz"
        case .stressed: return "estrés"
        case .excited: return "emoción"
        case .tired: return "cansancio"
        case .confused: return "confusión"
        }
    }
    
    private func generateContextSummary(_ context: EmotionAnalysisContext) -> String {
        var summary = ""
        
        switch context.timeOfDay {
        case .morning:
            summary += "Durante la mañana, "
        case .afternoon:
            summary += "En la tarde, "
        case .evening:
            summary += "Por la noche, "
        case .night:
            summary += "Tarde en la noche, "
        }
        
        if let stressLevel = context.stressLevel {
            summary += "tu nivel de estrés es \(stressLevel.rawValue) y "
        }
        
        if let sleepQuality = context.sleepQuality {
            summary += "la calidad de tu sueño reciente ha sido \(sleepQuality.rawValue)."
        }
        
        return summary
    }
    
    private func analyzeTimePatterns(_ history: [EmotionData]) -> [EmotionalInsight] {
        // Mock implementation - in real app would analyze actual time patterns
        return []
    }
    
    private func analyzeIntensityPatterns(_ history: [EmotionData]) -> [EmotionalInsight] {
        // Mock implementation - in real app would analyze intensity patterns
        return []
    }
    
    private func calculateTrendDirection(_ emotions: [EmotionData]) -> EmotionalTrend.TrendDirection {
        // Mock implementation - would analyze actual trends
        return .stable
    }
    
    private func calculateTrendConfidence(_ emotions: [EmotionData]) -> Double {
        // Mock implementation - would calculate actual confidence
        return 0.7
    }
    
    private func generateEmotionPredictions(_ emotions: [EmotionData]) -> [EmotionalTrend.EmotionPrediction] {
        // Mock implementation - would generate actual predictions
        return [
            EmotionalTrend.EmotionPrediction(
                emotion: .peaceful,
                probability: 0.6,
                timeframe: "próxima semana"
            )
        ]
    }
    
    private func identifyTrendFactors(_ emotions: [EmotionData]) -> [EmotionalTrend.TrendFactor] {
        // Mock implementation - would identify actual factors
        return [
            EmotionalTrend.TrendFactor(
                name: "Actividad física regular",
                impact: 0.3,
                description: "El ejercicio está contribuyendo positivamente a tu estado emocional"
            )
        ]
    }
}

// MARK: - Supporting Structures
private struct ResponseInsights {
    let totalResponses: Int
    let averageLength: Int
    let negativeKeywordCount: Int
    let positiveKeywordCount: Int
    let helpSeekingCount: Int
    let isDetailed: Bool
}
