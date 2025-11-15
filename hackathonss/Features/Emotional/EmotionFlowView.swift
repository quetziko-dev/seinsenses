import SwiftUI
import SwiftData

struct EmotionFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var users: [User]
    @State private var currentUser: User?
    
    @State private var currentStep: EmotionFlowStep = .emotionSelection
    @State private var selectedEmotion: EmotionType?
    @State private var emotionIntensity: Double = 0.5
    @State private var currentQuestionIndex = 0
    @State private var responses: [EmotionResponse] = []
    @State private var reflectionNotes = ""
    @State private var aiAnalysis: AIEmotionAnalysisResult?
    
    private let emotionQuestions = [
        "¿Qué crees que causó este sentimiento?",
        "¿Cómo te sientes físicamente con esta emoción?",
        "¿Qué podrías hacer para sentirte mejor?",
        "¿Hay alguien con quien te gustaría compartir esto?"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full background gradient extending to edges
                gradientBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator
                    
                    // Content based on current step
                    Group {
                        switch currentStep {
                        case .emotionSelection:
                            emotionSelectionView
                        case .intensitySelection:
                            intensitySelectionView
                        case .questionFlow:
                            questionFlowView
                        case .reflection:
                            reflectionView
                        case .analysis:
                            analysisView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                setupCurrentUser()
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index < currentStep.rawValue ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .padding(.top, 20)
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            colors: [Color.themeDeepBlue, Color.themeLavender],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var emotionSelectionView: some View {
        VStack(spacing: 30) {
            Text("¿Cómo te sientes hoy?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(EmotionType.allCases, id: \.self) { emotion in
                    EmotionSelectionCard(
                        emotion: emotion,
                        isSelected: selectedEmotion == emotion,
                        action: {
                            selectedEmotion = emotion
                        }
                    )
                }
            }
            
            Spacer()
            
            Button("Continuar") {
                if selectedEmotion != nil {
                    currentStep = .intensitySelection
                }
            }
            .disabled(selectedEmotion == nil)
            .buttonStyle(WhiteButtonStyle())
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
    }
    
    private var intensitySelectionView: some View {
        VStack(spacing: 30) {
            if let emotion = selectedEmotion {
                Text("¿Qué tan intenso es tu sentimiento?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                
                Text(emotion.icon)
                    .font(.system(size: 80))
                    .padding(.vertical, 20)
                
                Text(emotion.rawValue.capitalized)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    Slider(value: $emotionIntensity, in: 0...1)
                        .accentColor(.white)
                    
                    Text(intensityText)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("Atrás") {
                    currentStep = .emotionSelection
                }
                .buttonStyle(SecondaryWhiteButtonStyle())
                
                Button("Continuar") {
                    currentStep = .questionFlow
                }
                .buttonStyle(WhiteButtonStyle())
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
    }
    
    private var questionFlowView: some View {
        VStack(spacing: 30) {
            Text("Reflexionemos juntos")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            if currentQuestionIndex < emotionQuestions.count {
                VStack(spacing: 20) {
                    Text("Pregunta \(currentQuestionIndex + 1) de \(emotionQuestions.count)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(emotionQuestions[currentQuestionIndex])
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    DynamicTextEditor(text: $questionAnswer, placeholder: "Escribe tu respuesta aquí...")
                        .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("Atrás") {
                    if currentQuestionIndex > 0 {
                        currentQuestionIndex -= 1
                        loadPreviousAnswer()
                    } else {
                        currentStep = .intensitySelection
                    }
                }
                .buttonStyle(SecondaryWhiteButtonStyle())
                
                Button(currentQuestionIndex < emotionQuestions.count - 1 ? "Siguiente" : "Finalizar") {
                    saveCurrentAnswer()
                    
                    if currentQuestionIndex < emotionQuestions.count - 1 {
                        currentQuestionIndex += 1
                        questionAnswer = ""
                    } else {
                        currentStep = .reflection
                    }
                }
                .disabled(questionAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(WhiteButtonStyle())
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
    }
    
    private var reflectionView: some View {
        VStack(spacing: 30) {
            Text("Notas adicionales")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text("¿Hay algo más que quieras compartir sobre cómo te sientes?")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            DynamicTextEditor(text: $reflectionNotes, placeholder: "Escribe tus notas adicionales...")
                .padding(.horizontal, 20)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button("Atrás") {
                    currentStep = .questionFlow
                    currentQuestionIndex = emotionQuestions.count - 1
                }
                .buttonStyle(SecondaryWhiteButtonStyle())
                
                Button("Analizar") {
                    performAIAnalysis()
                }
                .buttonStyle(WhiteButtonStyle())
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
    }
    
    private var analysisView: some View {
        VStack(spacing: 30) {
            Text("Análisis Emocional")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            if let analysis = aiAnalysis {
                VStack(spacing: 20) {
                    // Severity indicator
                    HStack {
                        Text(analysis.severityLevel.icon)
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nivel: \(analysis.severityLevel.rawValue.capitalized)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(analysis.isSevere ? "Requiere atención" : "Estado estable")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    
                    // Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(analysis.summary)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    
                    // Suggested action
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sugerencia")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(analysis.suggestedAction)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button("Finalizar") {
                saveEmotionData()
                dismiss()
            }
            .buttonStyle(WhiteButtonStyle())
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
    }
    
    @State private var questionAnswer = ""
    
    private var intensityText: String {
        switch emotionIntensity {
        case 0.0..<0.2: return "Muy leve"
        case 0.2..<0.4: return "Leve"
        case 0.4..<0.6: return "Moderado"
        case 0.6..<0.8: return "Intenso"
        default: return "Muy intenso"
        }
    }
    
    private func setupCurrentUser() {
        if users.isEmpty {
            // Use registered name from AuthenticationManager, fallback to "Usuario"
            let userName = AuthenticationManager.shared.registeredUserName ?? "Usuario"
            let newUser = User(name: userName)
            modelContext.insert(newUser)
            currentUser = newUser
        } else {
            currentUser = users.first
        }
        
        // Initialize mood jar if it doesn't exist
        if let user = currentUser, user.moodJar == nil {
            user.moodJar = MoodJar()
        }
    }
    
    private func saveCurrentAnswer() {
        guard !questionAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let response = EmotionResponse(
            question: emotionQuestions[currentQuestionIndex],
            answer: questionAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        responses.append(response)
    }
    
    private func loadPreviousAnswer() {
        if currentQuestionIndex < responses.count {
            questionAnswer = responses[currentQuestionIndex].answer
        } else {
            questionAnswer = ""
        }
    }
    
    private func performAIAnalysis() {
        // Always use local intelligent analysis (más confiable)
        aiAnalysis = performLocalFallbackAnalysis()
        
        print("🔍 DEBUG - Análisis realizado:")
        print("  Emoción: \(selectedEmotion?.rawValue ?? "ninguna")")
        print("  Intensidad: \(emotionIntensity)")
        print("  Resultado: \(aiAnalysis?.severityLevel.rawValue ?? "error")")
        
        // Save emotion data
        saveEmotionData()
        
        // Move to analysis view
        currentStep = .analysis
    }
    
    private func performLocalFallbackAnalysis() -> AIEmotionAnalysisResult {
        guard let emotion = selectedEmotion else {
            return AIEmotionAnalysisResult(
                isSevere: false,
                severityLevel: .medium,
                summary: "No se pudo completar el análisis.",
                suggestedAction: "Intenta nuevamente más tarde."
            )
        }
        
        // Analyze based on emotion type and responses
        let allText = responses.map { $0.answer }.joined(separator: " ") + " " + reflectionNotes
        let lowercaseText = allText.lowercased()
        
        // Determine severity intelligently
        let severityLevel: AIEmotionAnalysisResult.SeverityLevel
        let isSevere: Bool
        
        // Check for positive emotions and content
        let positiveWords = ["feliz", "contento", "bien", "genial", "excelente", "alegre", "agradecido"]
        let negativeWords = ["triste", "mal", "horrible", "terrible", "desesperado", "ansioso"]
        let criticalWords = ["suicidio", "muerte", "morir", "no puedo más"]
        
        let hasPositive = positiveWords.contains { lowercaseText.contains($0) }
        let hasNegative = negativeWords.contains { lowercaseText.contains($0) }
        let hasCritical = criticalWords.contains { lowercaseText.contains($0) }
        
        if hasCritical {
            severityLevel = .critical
            isSevere = true
        } else if emotion == .happy || emotion == .grateful || emotion == .peaceful || emotion == .excited {
            if hasPositive || !hasNegative {
                severityLevel = .low
                isSevere = false
            } else {
                severityLevel = .medium
                isSevere = false
            }
        } else if emotion == .sad || emotion == .anxious || emotion == .angry || emotion == .stressed {
            if emotionIntensity > 0.7 || hasNegative {
                severityLevel = .high
                isSevere = true
            } else {
                severityLevel = .medium
                isSevere = false
            }
        } else {
            severityLevel = .medium
            isSevere = false
        }
        
        let summary = generateSummary(emotion: emotion, severity: severityLevel)
        let action = generateAction(emotion: emotion, severity: severityLevel)
        
        return AIEmotionAnalysisResult(
            isSevere: isSevere,
            severityLevel: severityLevel,
            summary: summary,
            suggestedAction: action
        )
    }
    
    private func generateSummary(emotion: EmotionType, severity: AIEmotionAnalysisResult.SeverityLevel) -> String {
        switch severity {
        case .low:
            return "Tu estado emocional es positivo y saludable. ¡Sigue así!"
        case .medium:
            return "Estás experimentando emociones normales que requieren atención y cuidado."
        case .high:
            return "Tu estado emocional muestra signos de malestar que podrían beneficiarse de apoyo."
        case .critical:
            return "Se detectan señales de crisis emocional que requieren atención inmediata."
        }
    }
    
    private func generateAction(emotion: EmotionType, severity: AIEmotionAnalysisResult.SeverityLevel) -> String {
        switch severity {
        case .low:
            return "Continúa con tus prácticas de bienestar y comparte tu energía positiva con otros."
        case .medium:
            return "Practica técnicas de relajación, habla con alguien de confianza y cuida tu autocuidado."
        case .high:
            return "Considera hablar con un profesional de salud mental y practica técnicas de regulación emocional."
        case .critical:
            return "🚨 Contacta inmediatamente con un profesional de salud mental o línea de ayuda: 911 o Línea de la Vida 800 911 2000."
        }
    }
    
    private func saveEmotionData() {
        guard let user = currentUser,
              let emotion = selectedEmotion,
              let moodJar = user.moodJar else { return }
        
        // Create emotion data
        let emotionData = EmotionData(
            emotion: emotion,
            intensity: emotionIntensity,
            responses: responses
        )
        emotionData.aiAnalysis = aiAnalysis
        emotionData.reflectionNotes = reflectionNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add to user's emotions
        user.emotions.append(emotionData)
        
        // Add to mood jar
        moodJar.addMarble(emotion: emotion, intensity: emotionIntensity)
        
        // Update panther progress
        user.pantherProgress.addExperience(points: 15)
        user.pantherProgress.updateDailyActivity()
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving emotion data: \(error)")
        }
    }
}

enum EmotionFlowStep: Int, CaseIterable {
    case emotionSelection = 0
    case intensitySelection = 1
    case questionFlow = 2
    case reflection = 3
    case analysis = 4
}

struct EmotionSelectionCard: View {
    let emotion: EmotionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emotion.icon)
                    .font(.system(size: 30))
                
                Text(emotion.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.white : Color.white.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.themeTeal : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.15), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WhiteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.themeDeepBlue)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryWhiteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Dynamic Text Editor
struct DynamicTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @State private var textHeight: CGFloat = 60
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
            
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(.body)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            // TextEditor with dynamic height
            TextEditor(text: $text)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(height: max(60, min(textHeight, 200)))
                .onChange(of: text) { _ in
                    updateHeight()
                }
                .onAppear {
                    updateHeight()
                }
        }
        .frame(height: max(60, min(textHeight, 200)))
    }
    
    private func updateHeight() {
        let size = text.boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width - 80, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .body)],
            context: nil
        )
        
        // Add padding and ensure minimum height
        let newHeight = size.height + 40
        textHeight = max(60, min(newHeight, 200))
    }
}

#Preview {
    EmotionFlowView()
        .modelContainer(for: [User.self, MoodJar.self, EmotionData.self, EmotionResponse.self], inMemory: true)
}
