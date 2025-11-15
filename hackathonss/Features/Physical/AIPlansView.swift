import SwiftUI
import SwiftData

struct AIPlansView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @StateObject private var viewModel = AIPlansViewModel()
    
    private var currentUser: User? {
        users.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Profile summary if exists
                    if let profile = viewModel.physicalProfile {
                        profileSummaryCard(profile: profile)
                    }
                    
                    // Generation status
                    if viewModel.isGeneratingPlan {
                        generatingView
                    } else if viewModel.workoutPlan != nil && viewModel.dietPlan != nil {
                        // Show generated plans
                        workoutPlanCard
                        dietPlanCard
                        disclaimerCard
                    } else {
                        // Start button
                        startButton
                    }
                    
                    // Error message
                    if let error = viewModel.generationError {
                        errorView(message: error)
                    }
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Plan Personalizado IA")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showingProfileQuestions) {
                PhysicalProfileQuestionsFlow { profile in
                    viewModel.saveProfile(profile, context: modelContext, user: currentUser)
                }
            }
            .onAppear {
                viewModel.loadExistingData(from: currentUser)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.themeTeal)
                Text("Powered by AI")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Tu Plan Personalizado")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("Rutina de ejercicio y guía de alimentación adaptada a tus objetivos")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func profileSummaryCard(profile: PhysicalProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: profile.goal.icon)
                    .foregroundColor(.themeTeal)
                Text("Objetivo: \(profile.goal.displayName)")
                    .font(.headline)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ProfileStatRow(label: "Días/semana", value: "\(profile.activityDaysPerWeek)")
                ProfileStatRow(label: "Duración", value: "\(profile.sessionDurationMinutes) min")
                ProfileStatRow(label: "Lugar", value: profile.workoutLocation == "gym" ? "Gimnasio" : "Casa")
                ProfileStatRow(label: "IMC", value: String(format: "%.1f", profile.bmi))
            }
            
            Button(action: {
                viewModel.showingProfileQuestions = true
            }) {
                Text("Actualizar perfil")
                    .font(.caption)
                    .foregroundColor(.themeTeal)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var startButton: some View {
        Button(action: {
            if viewModel.physicalProfile == nil {
                viewModel.showingProfileQuestions = true
            } else {
                Task {
                    await viewModel.generatePlans(context: modelContext, user: currentUser)
                }
            }
        }) {
            HStack {
                Image(systemName: "wand.and.stars")
                Text(viewModel.physicalProfile == nil ? "Crear Mi Plan" : "Regenerar Plan")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.themeTeal)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var generatingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Creando tu plan personalizado...")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("Analizando tus datos y objetivos")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var workoutPlanCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title2)
                    .foregroundColor(.themeTeal)
                Text("Tu Rutina Ideal")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            if let workout = viewModel.workoutPlan {
                Text(workout.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Focus areas
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enfoque:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(workout.focusAreas, id: \.self) { area in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.themeTeal)
                            Text(area)
                                .font(.caption)
                        }
                    }
                }
                
                // Daily plan
                ForEach(workout.dailyPlan) { day in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.day)
                            .font(.headline)
                            .foregroundColor(.themePrimaryDarkGreen)
                        Text(day.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(day.exercises, id: \.self) { exercise in
                            Text("• \(exercise)")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var dietPlanCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundColor(.themePrimaryDarkGreen)
                Text("Guía de Alimentación")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            if let diet = viewModel.dietPlan {
                Text(diet.summary)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Macros
                if let calories = diet.caloriesApprox {
                    HStack(spacing: 20) {
                        MacroView(label: "Calorías", value: "\(calories)", unit: "kcal")
                        MacroView(label: "Proteína", value: "\(diet.proteinGramsApprox ?? 0)", unit: "g")
                        MacroView(label: "Carbos", value: "\(diet.carbsGramsApprox ?? 0)", unit: "g")
                        MacroView(label: "Grasas", value: "\(diet.fatsGramsApprox ?? 0)", unit: "g")
                    }
                    .font(.caption)
                }
                
                // Guidelines
                VStack(alignment: .leading, spacing: 8) {
                    Text("Principios:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(diet.guidelines, id: \.self) { guideline in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.themePrimaryDarkGreen)
                            Text(guideline)
                                .font(.caption)
                        }
                    }
                }
                
                // Example menu
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ejemplo de Menú Diario:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    MealSection(title: "Desayuno", items: diet.exampleDayMenu.breakfast)
                    MealSection(title: "Snack AM", items: diet.exampleDayMenu.midMorningSnack)
                    MealSection(title: "Comida", items: diet.exampleDayMenu.lunch)
                    MealSection(title: "Snack PM", items: diet.exampleDayMenu.afternoonSnack)
                    MealSection(title: "Cena", items: diet.exampleDayMenu.dinner)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Importante")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text("Estas recomendaciones son sugerencias generales de estilo de vida generadas por IA. NO son asesoría médica, nutricional o de entrenamiento profesional. Consulta a profesionales de salud antes de iniciar cambios importantes en tu dieta o rutina de ejercicio.")
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
    }
    
    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Reintentar") {
                Task {
                    await viewModel.generatePlans(context: modelContext, user: currentUser)
                }
            }
            .font(.caption)
            .foregroundColor(.themeTeal)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views
struct ProfileStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct MacroView: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.themeLightAqua.opacity(0.3))
        .cornerRadius(8)
    }
}

struct MealSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.themeTeal)
            
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
class AIPlansViewModel: ObservableObject {
    @Published var physicalProfile: PhysicalProfile?
    @Published var workoutPlan: WorkoutPlan?
    @Published var dietPlan: DietPlan?
    @Published var isGeneratingPlan = false
    @Published var generationError: String?
    @Published var showingProfileQuestions = false
    
    private let aiService: PhysicalAIServiceProtocol = MockPhysicalAIService.shared
    
    // Load existing data when view appears
    func loadExistingData(from user: User?) {
        guard let user = user else { return }
        
        // Load physical profile
        if let profile = user.physicalProfile {
            self.physicalProfile = profile
        }
        
        // Load generated plans
        if let plans = user.generatedPlans {
            self.workoutPlan = plans.workoutPlan
            self.dietPlan = plans.dietPlan
        }
    }
    
    func saveProfile(_ profile: PhysicalProfile, context: ModelContext, user: User?) {
        guard let user = user else { return }
        
        // Save or update profile in SwiftData
        if let existingProfile = user.physicalProfile {
            // Update existing
            existingProfile.heightCm = profile.heightCm
            existingProfile.weightKg = profile.weightKg
            existingProfile.age = profile.age
            existingProfile.sex = profile.sex
            existingProfile.activityDaysPerWeek = profile.activityDaysPerWeek
            existingProfile.sessionDurationMinutes = profile.sessionDurationMinutes
            existingProfile.workoutLocation = profile.workoutLocation
            existingProfile.goal = profile.goal
            existingProfile.updatedAt = Date()
            self.physicalProfile = existingProfile
        } else {
            // Create new
            context.insert(profile)
            user.physicalProfile = profile
            self.physicalProfile = profile
        }
        
        do {
            try context.save()
            showingProfileQuestions = false
            
            // Auto-generate plans
            Task {
                await generatePlans(context: context, user: user)
            }
        } catch {
            generationError = "Error al guardar perfil: \(error.localizedDescription)"
        }
    }
    
    func generatePlans(context: ModelContext, user: User?) async {
        guard let profile = physicalProfile, let user = user else {
            generationError = "Completa tu perfil primero"
            return
        }
        
        isGeneratingPlan = true
        generationError = nil
        
        do {
            let (workout, diet) = try await aiService.generateWorkoutAndDiet(for: profile)
            
            await MainActor.run {
                self.workoutPlan = workout
                self.dietPlan = diet
                self.isGeneratingPlan = false
                
                // Save plans to SwiftData
                if let existingPlans = user.generatedPlans {
                    // Update existing
                    existingPlans.workoutPlan = workout
                    existingPlans.dietPlan = diet
                } else {
                    // Create new
                    let newPlans = GeneratedPlans()
                    newPlans.workoutPlan = workout
                    newPlans.dietPlan = diet
                    context.insert(newPlans)
                    user.generatedPlans = newPlans
                }
                
                do {
                    try context.save()
                    print("✅ Planes guardados exitosamente en SwiftData")
                } catch {
                    self.generationError = "Error al guardar planes: \(error.localizedDescription)"
                }
            }
        } catch {
            await MainActor.run {
                self.isGeneratingPlan = false
                self.generationError = "No pudimos generar tu plan. Intenta más tarde."
            }
        }
    }
}

#Preview {
    AIPlansView()
}
