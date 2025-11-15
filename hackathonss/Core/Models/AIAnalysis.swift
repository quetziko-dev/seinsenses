import Foundation

struct AIEmotionAnalysisResult: Codable {
    let isSevere: Bool
    let severityLevel: SeverityLevel
    let summary: String
    let suggestedAction: String
    
    enum SeverityLevel: String, Codable, CaseIterable {
        case low = "bajo"
        case medium = "medio"
        case high = "alto"
        case critical = "crítico"
        
        var color: String {
            switch self {
            case .low: return "#4CAF50"
            case .medium: return "#FFC107"
            case .high: return "#FF9800"
            case .critical: return "#F44336"
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "✅"
            case .medium: return "⚠️"
            case .high: return "🔶"
            case .critical: return "🚨"
            }
        }
    }
}

// Mock data for testing
extension AIEmotionAnalysisResult {
    static let mockResults: [AIEmotionAnalysisResult] = [
        AIEmotionAnalysisResult(
            isSevere: false,
            severityLevel: .low,
            summary: "Tu estado emocional es estable y positivo. Continúa con tus prácticas actuales de bienestar.",
            suggestedAction: "Mantén tu rutina de ejercicio y meditación diaria."
        ),
        AIEmotionAnalysisResult(
            isSevere: false,
            severityLevel: .medium,
            summary: "Detecté algunos signos de estrés moderado. Es importante prestar atención a tu autocuidado.",
            suggestedAction: "Considera técnicas de respiración profunda y pausas activas durante el día."
        ),
        AIEmotionAnalysisResult(
            isSevere: true,
            severityLevel: .high,
            summary: "Niveles elevados de ansiedad detectados. Te recomiendo buscar apoyo adicional.",
            suggestedAction: "Habla con un profesional de salud mental y practica técnicas de grounding."
        ),
        AIEmotionAnalysisResult(
            isSevere: true,
            severityLevel: .critical,
            summary: "Estado emocional crítico detectado. Es importante buscar ayuda profesional inmediatamente.",
            suggestedAction: "Contacta a un profesional de salud mental o línea de ayuda emocional."
        )
    ]
}
