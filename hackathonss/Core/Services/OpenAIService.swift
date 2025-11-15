import Foundation

// MARK: - OpenAI Service for Real AI Analysis
class OpenAIService {
    static let shared = OpenAIService()
    
    private let apiKey = "YOUR_OPENAI_API_KEY_HERE" // TODO: Agregar tu API Key
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    func analyzeEmotionalState(
        emotion: EmotionType,
        intensity: Double,
        responses: [EmotionResponse],
        reflectionNotes: String
    ) async throws -> AIEmotionAnalysisResult {
        
        // Build the prompt for OpenAI
        let prompt = buildAnalysisPrompt(
            emotion: emotion,
            intensity: intensity,
            responses: responses,
            reflectionNotes: reflectionNotes
        )
        
        // Make API call
        let analysis = try await callOpenAI(prompt: prompt)
        
        return analysis
    }
    
    private func buildAnalysisPrompt(
        emotion: EmotionType,
        intensity: Double,
        responses: [EmotionResponse],
        reflectionNotes: String
    ) -> String {
        var prompt = """
        Eres un psicólogo experto en análisis emocional. Analiza el siguiente estado emocional de un usuario y determina:
        1. Nivel de severidad (low, medium, high, critical)
        2. Si requiere atención profesional (isSevere: true/false)
        3. Un resumen breve del estado emocional
        4. Una sugerencia de acción personalizada
        
        IMPORTANTE: 
        - Si el usuario expresa felicidad, gratitud o paz, debe ser "low" (excelente)
        - Si expresa tristeza leve o estrés manejable, debe ser "medium" (moderado)
        - Si expresa ansiedad intensa o tristeza profunda, debe ser "high" (preocupante)
        - Solo usa "critical" si hay indicios de crisis, pensamientos autodestructivos o emergencia
        
        Información del usuario:
        - Emoción seleccionada: \(emotion.rawValue)
        - Intensidad (0-10): \(String(format: "%.1f", intensity * 10))
        
        Respuestas a preguntas:
        """
        
        for (index, response) in responses.enumerated() {
            prompt += "\nPregunta \(index + 1): \(response.question)\n"
            prompt += "Respuesta: \(response.answer)\n"
        }
        
        if !reflectionNotes.isEmpty {
            prompt += "\nNotas adicionales: \(reflectionNotes)\n"
        }
        
        prompt += """
        
        Responde ÚNICAMENTE con un JSON válido en este formato exacto:
        {
            "isSevere": false,
            "severityLevel": "low",
            "summary": "Descripción breve del estado emocional",
            "suggestedAction": "Sugerencia personalizada de acción"
        }
        
        Valores válidos para severityLevel: "low", "medium", "high", "critical"
        """
        
        return prompt
    }
    
    private func callOpenAI(prompt: String) async throws -> AIEmotionAnalysisResult {
        // Check if API key is configured
        guard apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
            print("⚠️ OpenAI API Key no configurada, usando análisis inteligente local")
            return performLocalIntelligentAnalysis(prompt: prompt)
        }
        
        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "Eres un psicólogo experto. Responde solo con JSON válido."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIError.invalidResponse
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = openAIResponse.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        
        // Parse JSON response from OpenAI
        return try parseAnalysisFromJSON(content)
    }
    
    private func parseAnalysisFromJSON(_ jsonString: String) throws -> AIEmotionAnalysisResult {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw OpenAIError.invalidJSON
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(AIEmotionAnalysisResult.self, from: jsonData)
    }
    
    // MARK: - Local Intelligent Analysis (Fallback cuando no hay API Key)
    private func performLocalIntelligentAnalysis(prompt: String) -> AIEmotionAnalysisResult {
        let lowercasePrompt = prompt.lowercased()
        
        // Palabras clave para análisis
        let criticalKeywords = ["suicidio", "muerte", "morir", "acabar con", "no quiero vivir", "terminar con todo"]
        let highKeywords = ["muy triste", "desesperado", "no puedo más", "ansiedad severa", "pánico", "crisis"]
        let mediumKeywords = ["triste", "preocupado", "estresado", "ansioso", "nervioso", "agobiado"]
        let lowKeywords = ["feliz", "contento", "agradecido", "en paz", "tranquilo", "alegre", "bien", "genial"]
        
        // Detectar severidad basada en palabras clave
        let severityLevel: AIEmotionAnalysisResult.SeverityLevel
        let isSevere: Bool
        let summary: String
        let suggestedAction: String
        
        if criticalKeywords.contains(where: { lowercasePrompt.contains($0) }) {
            severityLevel = .critical
            isSevere = true
            summary = "Se detectan señales de crisis emocional que requieren atención profesional inmediata."
            suggestedAction = "🚨 Por favor, contacta con un profesional de salud mental de inmediato. En caso de emergencia, llama a servicios de emergencia o líneas de ayuda: 911 o Línea de la Vida 800 911 2000."
            
        } else if highKeywords.contains(where: { lowercasePrompt.contains($0) }) {
            severityLevel = .high
            isSevere = true
            summary = "Tu estado emocional muestra signos de malestar significativo que podrían beneficiarse de apoyo profesional."
            suggestedAction = "Te recomendamos hablar con un profesional de salud mental. Mientras tanto, practica técnicas de respiración profunda y contacta con personas de confianza."
            
        } else if mediumKeywords.contains(where: { lowercasePrompt.contains($0) }) {
            severityLevel = .medium
            isSevere = false
            summary = "Estás experimentando emociones desafiantes que son normales. Es importante reconocerlas y gestionarlas adecuadamente."
            suggestedAction = "Practica técnicas de relajación, habla con alguien de confianza y considera actividades que te ayuden a reducir el estrés como caminar o meditar."
            
        } else if lowKeywords.contains(where: { lowercasePrompt.contains($0) }) {
            severityLevel = .low
            isSevere = false
            summary = "Tu estado emocional es positivo y estable. ¡Sigue cultivando estos sentimientos!"
            suggestedAction = "Aprovecha esta energía positiva para compartir tu alegría con otros, practicar gratitud y disfrutar actividades que te hacen feliz."
            
        } else {
            // Default a medium si no se detectan palabras clave específicas
            severityLevel = .medium
            isSevere = false
            summary = "Tu estado emocional parece estar en un punto neutral. Es un buen momento para reflexionar sobre cómo te sientes."
            suggestedAction = "Tómate un tiempo para conectar contigo mismo, practica mindfulness y mantén hábitos saludables."
        }
        
        return AIEmotionAnalysisResult(
            isSevere: isSevere,
            severityLevel: severityLevel,
            summary: summary,
            suggestedAction: suggestedAction
        )
    }
}

// MARK: - OpenAI Response Models
private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

// MARK: - Errors
enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noContent
    case invalidJSON
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de API inválida"
        case .invalidResponse:
            return "Respuesta de API inválida"
        case .noContent:
            return "No se recibió contenido de la API"
        case .invalidJSON:
            return "JSON de respuesta inválido"
        }
    }
}
