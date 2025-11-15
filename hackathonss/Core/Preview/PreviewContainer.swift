import SwiftUI
import SwiftData

// MARK: - Preview Container
@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: User.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        // Create sample data for previews
        createSampleData(context: container.mainContext)
        
        return container
    } catch {
        fatalError("Failed to create preview container: \(error)")
    }
}()

// MARK: - Preview Data Creation
@MainActor
private func createSampleData(context: ModelContext) {
    // Create sample user
    let user = User(name: "Usuario de Prueba")
    
    // Setup physical data
    let physicalData = PhysicalData(height: 170, weight: 70, weeklyGoal: 5)
    user.physicalData = physicalData
    physicalData.user = user
    
    // Add sample activities
    let runningActivity = PhysicalActivity(
        type: .running,
        duration: 30,
        date: Date().addingTimeInterval(-86400), // Yesterday
        caloriesBurned: 300
    )
    runningActivity.physicalData = physicalData
    physicalData.activities.append(runningActivity)
    
    let yogaActivity = PhysicalActivity(
        type: .yoga,
        duration: 45,
        date: Date().addingTimeInterval(-172800), // 2 days ago
        caloriesBurned: 150
    )
    yogaActivity.physicalData = physicalData
    physicalData.activities.append(yogaActivity)
    
    // Setup mood jar
    let moodJar = MoodJar()
    user.moodJar = moodJar
    moodJar.user = user
    
    // Add sample mood marbles
    moodJar.addMarble(emotion: .happy, intensity: 0.8)
    moodJar.addMarble(emotion: .grateful, intensity: 0.9)
    moodJar.addMarble(emotion: .peaceful, intensity: 0.7)
    moodJar.addMarble(emotion: .excited, intensity: 0.6)
    
    // Setup panther progress
    user.pantherProgress.addExperience(points: 150)
    user.pantherProgress.updateDailyActivity()
    
    // Add sample emotion entries
    let emotionResponse1 = EmotionResponse(
        question: "¿Cómo te sientes hoy?",
        answer: "Me siento bastante bien y energético."
    )
    let emotionResponse2 = EmotionResponse(
        question: "¿Qué ha influido en tu estado de ánimo?",
        answer: "El buen tiempo y haber dormido bien."
    )
    let emotionResponse3 = EmotionResponse(
        question: "¿Qué puedes hacer para mantenerte así?",
        answer: "Continuar con mi rutina de ejercicio."
    )
    let emotionResponse4 = EmotionResponse(
        question: "¿Necesitas apoyo en algo específico?",
        answer: "No realmente, me siento bien equilibrado."
    )
    
    let emotionData = EmotionData(
        emotion: .happy,
        intensity: 0.8,
        responses: [emotionResponse1, emotionResponse2, emotionResponse3, emotionResponse4]
    )
    emotionData.user = user
    user.emotions.append(emotionData)
    
    // Add sample sleep data
    let sleepData = SleepData(
        bedTime: Date().addingTimeInterval(-32400), // 9 hours ago
        wakeTime: Date().addingTimeInterval(-3600),  // 1 hour ago
        quality: .good,
        notes: "Dormí bien toda la noche."
    )
    sleepData.user = user
    user.sleepData.append(sleepData)
    
    // Save all data
    try? context.save()
}

// MARK: - Preview Helper
struct PreviewWrapper<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .modelContainer(previewContainer)
    }
}

// MARK: - Preview Extensions
extension View {
    func previewWithContainer() -> some View {
        self.modelContainer(previewContainer)
    }
}

// MARK: - Sample Data for Testing
enum PreviewDataProvider {
    @MainActor
    static var sampleUser: User {
        let descriptor = FetchDescriptor<User>()
        return (try? previewContainer.mainContext.fetch(descriptor))?.first ?? User(name: "Default User")
    }
    
    @MainActor
    static var samplePhysicalData: PhysicalData? {
        return sampleUser.physicalData
    }
    
    @MainActor
    static var sampleMoodJar: MoodJar? {
        return sampleUser.moodJar
    }
    
    @MainActor
    static var samplePantherProgress: PantherProgress {
        return sampleUser.pantherProgress
    }
}
