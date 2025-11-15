import SwiftUI

struct EmotionalAnalysisFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmotionalAnalysisViewModel()
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.themeDeepBlue, Color.themeLavender],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.showingResults {
                // Results View
                ResultsView(result: viewModel.analysisResult!)
                    .transition(.move(edge: .trailing))
            } else {
                // Questions Flow
                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 4)
                            
                            Rectangle()
                                .fill(Color.white)
                                .frame(
                                    width: geometry.size.width * CGFloat(viewModel.currentQuestionIndex + 1) / CGFloat(viewModel.questions.count),
                                    height: 4
                                )
                        }
                    }
                    .frame(height: 4)
                    
                    // Question content
                    ScrollView {
                        VStack(spacing: 30) {
                            Spacer(minLength: 40)
                            
                            questionContent
                            
                            Spacer(minLength: 40)
                        }
                        .padding()
                    }
                    
                    // Navigation buttons
                    navigationButtons
                        .padding()
                }
            }
            
            // Loading overlay
            if viewModel.isAnalyzing {
                analysingOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(viewModel.analysisError != nil)) {
            Button("OK") {
                viewModel.analysisError = nil
            }
        } message: {
            if let error = viewModel.analysisError {
                Text(error)
            }
        }
    }
    
    @ViewBuilder
    private var questionContent: some View {
        let currentQuestion = viewModel.questions[viewModel.currentQuestionIndex]
        
        VStack(spacing: 20) {
            Text("Pregunta \(viewModel.currentQuestionIndex + 1) de \(viewModel.questions.count)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(currentQuestion.text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            TextEditor(text: $viewModel.answers[viewModel.currentQuestionIndex])
                .frame(minHeight: 200)
                .padding(12)
                .background(Color.white.opacity(0.9))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1)
                )
            
            Text("\(viewModel.answers[viewModel.currentQuestionIndex].count)/600 caracteres")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentQuestionIndex > 0 {
                Button(action: {
                    withAnimation {
                        viewModel.previousQuestion()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                }
                .buttonStyle(SecondaryAnalysisButtonStyle())
            }
            
            Button(action: {
                if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                    withAnimation {
                        viewModel.nextQuestion()
                    }
                } else {
                    Task {
                        await viewModel.analyzeAnswers()
                    }
                }
            }) {
                Text(viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "Siguiente" : "Analizar")
                    .fontWeight(.semibold)
            }
            .buttonStyle(PrimaryAnalysisButtonStyle())
            .disabled(viewModel.answers[viewModel.currentQuestionIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    private var analysingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Analizando tus respuestas...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Esto tomará solo un momento")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(Color.themeDeepBlue.opacity(0.9))
            .cornerRadius(20)
        }
    }
}

// MARK: - Results View
struct ResultsView: View {
    let result: IAEmotionAnalysisResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text(result.severityLevel.emoji)
                        .font(.system(size: 80))
                    
                    Text(result.emotionalState)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Análisis Emocional")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                
                // Summary Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.text.square")
                            .foregroundColor(Color(hex: result.severityLevel.color))
                        Text("Resumen")
                            .font(.headline)
                    }
                    
                    Text(result.summary)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Suggested Actions Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.themeTeal)
                        Text("Sugerencias")
                            .font(.headline)
                    }
                    
                    ForEach(Array(result.suggestedActions.enumerated()), id: \.offset) { index, action in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.themeTeal)
                                .clipShape(Circle())
                            
                            Text(action)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Disclaimer Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Importante")
                            .font(.headline)
                    }
                    
                    Text("Este análisis es una herramienta de apoyo y reflexión personal. NO es un diagnóstico médico ni psicológico. Si te sientes muy mal o en riesgo, busca ayuda profesional inmediatamente.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
                
                // Close button
                Button(action: {
                    dismiss()
                }) {
                    Text("Finalizar")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.themeDeepBlue)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.themeDeepBlue, Color.themeLavender],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - ViewModel
@MainActor
class EmotionalAnalysisViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var answers: [String]
    @Published var isAnalyzing = false
    @Published var analysisResult: IAEmotionAnalysisResult?
    @Published var analysisError: String?
    @Published var showingResults = false
    
    private let aiService: EmotionalAIServiceProtocol = MockEmotionalAIService.shared
    
    let questions: [Question] = [
        Question(text: "¿Cómo te has sentido en general estos últimos días?"),
        Question(text: "¿Hay algo que te preocupe especialmente en este momento?"),
        Question(text: "¿Cómo han estado tus niveles de energía últimamente?"),
        Question(text: "¿Qué cosas te han generado alegría o satisfacción recientemente?"),
        Question(text: "¿Cómo describirías la calidad de tu sueño?"),
        Question(text: "¿Qué te gustaría mejorar de tu bienestar emocional?")
    ]
    
    struct Question: Identifiable {
        let id = UUID()
        let text: String
    }
    
    init() {
        self.answers = Array(repeating: "", count: questions.count)
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func analyzeAnswers() async {
        isAnalyzing = true
        analysisError = nil
        
        // Create reflective answers
        let reflectiveAnswers = zip(questions, answers).map { question, answer in
            ReflectiveAnswer(question: question.text, answer: answer)
        }
        
        do {
            let result = try await aiService.analyze(answers: reflectiveAnswers)
            
            await MainActor.run {
                self.analysisResult = result
                self.isAnalyzing = false
                
                // Show results with animation
                withAnimation {
                    self.showingResults = true
                }
                
                // If severe, notify panther system (future integration)
                if result.isSevere {
                    print("⚠️ Usuario en estado emocional difícil - notificar pantera")
                }
            }
        } catch {
            await MainActor.run {
                self.isAnalyzing = false
                self.analysisError = "No pudimos analizar tus respuestas. Intenta de nuevo más tarde."
            }
        }
    }
}

// MARK: - Button Styles
struct PrimaryAnalysisButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.themeDeepBlue)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryAnalysisButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    NavigationStack {
        EmotionalAnalysisFlowView()
    }
}
