import Foundation
import SwiftData

// MARK: - Wellness Service Protocol
protocol WellnessServiceProtocol {
    func createUser(name: String) async throws -> User
    func updateUserPhysicalData(userId: UUID, height: Double, weight: Double, weeklyGoal: Int) async throws
    func addPhysicalActivity(userId: UUID, type: ActivityType, duration: Int, calories: Int?) async throws
    func addEmotionEntry(userId: UUID, emotion: EmotionType, intensity: Double, responses: [EmotionResponse]) async throws
    func addSleepData(userId: UUID, bedTime: Date, wakeTime: Date, quality: SleepQuality, notes: String?) async throws
    func getUserProgress(userId: UUID) async throws -> WellnessProgressSummary
    func getWeeklyStats(userId: UUID) async throws -> WeeklyStats
}

// MARK: - Wellness Progress Summary
struct WellnessProgressSummary {
    let user: User
    let physicalStats: PhysicalStats
    let emotionalStats: EmotionalStats
    let sleepStats: SleepStats
    let pantherStats: PantherStats
    let overallScore: Double
    let lastUpdated: Date
    
    struct PhysicalStats {
        let currentWeight: Double
        let bmi: Double
        let weeklyActivityDays: Int
        let weeklyGoal: Int
        let totalActivities: Int
        let caloriesBurnedThisWeek: Int
    }
    
    struct EmotionalStats {
        let totalEmotionEntries: Int
        let currentMood: EmotionType?
        let moodTrend: [EmotionType]
        let lastAnalysis: AIEmotionAnalysisResult?
        let consecutiveDaysTracked: Int
    }
    
    struct SleepStats {
        let averageHours: Double
        let averageQuality: SleepQuality
        let lastWeekEntries: Int
        let sleepEfficiency: Double
    }
    
    struct PantherStats {
        let currentLevel: PantherLevel
        let experiencePoints: Int
        let progressToNextLevel: Double
        let consecutiveDays: Int
        let unlockedFeatures: Set<String>
    }
}

// MARK: - Weekly Stats
struct WeeklyStats {
    let weekStart: Date
    let weekEnd: Date
    let activitiesCompleted: Int
    let emotionsTracked: Int
    let sleepHours: Double
    let sleepQuality: SleepQuality
    let experienceEarned: Int
    let goalsAchieved: [String]
}

// MARK: - Wellness Service Implementation
class WellnessService: WellnessServiceProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - User Management
    func createUser(name: String) async throws -> User {
        let user = User(name: name)
        
        // Initialize related entities
        user.physicalData = PhysicalData(height: 170, weight: 70, weeklyGoal: 5)
        user.moodJar = MoodJar()
        
        modelContext.insert(user)
        
        do {
            try modelContext.save()
            return user
        } catch {
            throw WellnessError.creationFailed("Failed to create user: \(error.localizedDescription)")
        }
    }
    
    func getUserById(_ userId: UUID) async throws -> User? {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { $0.id == userId }
        )
        
        do {
            let users = try modelContext.fetch(descriptor)
            return users.first
        } catch {
            throw WellnessError.fetchFailed("Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Physical Data Management
    func updateUserPhysicalData(userId: UUID, height: Double, weight: Double, weeklyGoal: Int) async throws {
        guard let user = try await getUserById(userId) else {
            throw WellnessError.userNotFound
        }
        
        if user.physicalData == nil {
            user.physicalData = PhysicalData(height: height, weight: weight, weeklyGoal: weeklyGoal)
        } else {
            user.physicalData?.height = height
            user.physicalData?.weight = weight
            user.physicalData?.weeklyGoal = weeklyGoal
            user.physicalData?.lastUpdated = Date()
        }
        
        do {
            try modelContext.save()
        } catch {
            throw WellnessError.updateFailed("Failed to update physical data: \(error.localizedDescription)")
        }
    }
    
    func addPhysicalActivity(userId: UUID, type: ActivityType, duration: Int, calories: Int?) async throws {
        guard let user = try await getUserById(userId) else {
            throw WellnessError.userNotFound
        }
        
        guard let physicalData = user.physicalData else {
            throw WellnessError.physicalDataNotFound
        }
        
        let activity = PhysicalActivity(
            type: type,
            duration: duration,
            date: Date(),
            caloriesBurned: calories
        )
        
        physicalData.activities.append(activity)
        updateActivityDays(physicalData: physicalData)
        
        // Award experience points
        let experiencePoints = calculateActivityExperience(type: type, duration: duration)
        user.pantherProgress.addExperience(points: experiencePoints)
        user.pantherProgress.updateDailyActivity()
        
        do {
            try modelContext.save()
        } catch {
            throw WellnessError.creationFailed("Failed to add activity: \(error.localizedDescription)")
        }
    }
    
    func getPhysicalActivities(userId: UUID, fromDate: Date? = nil, toDate: Date? = nil) async throws -> [PhysicalActivity] {
        guard let user = try await getUserById(userId),
              let physicalData = user.physicalData else {
            return []
        }
        
        var activities = physicalData.activities
        
        if let fromDate = fromDate {
            activities = activities.filter { $0.date >= fromDate }
        }
        
        if let toDate = toDate {
            activities = activities.filter { $0.date <= toDate }
        }
        
        return activities.sorted { $0.date > $1.date }
    }
    
    // MARK: - Emotional Data Management
    func addEmotionEntry(userId: UUID, emotion: EmotionType, intensity: Double, responses: [EmotionResponse]) async throws {
        guard let user = try await getUserById(userId) else {
            throw WellnessError.userNotFound
        }
        
        if user.moodJar == nil {
            user.moodJar = MoodJar()
        }
        
        let emotionData = EmotionData(
            emotion: emotion,
            intensity: intensity,
            responses: responses
        )
        
        // Add to mood jar
        user.moodJar?.addMarble(emotion: emotion, intensity: intensity)
        
        // Award experience points
        let experiencePoints = calculateEmotionExperience(emotion: emotion, responseCount: responses.count)
        user.pantherProgress.addExperience(points: experiencePoints)
        user.pantherProgress.updateDailyActivity()
        
        user.emotions.append(emotionData)
        
        do {
            try modelContext.save()
        } catch {
            throw WellnessError.creationFailed("Failed to add emotion entry: \(error.localizedDescription)")
        }
    }
    
    func updateEmotionAnalysis(userId: UUID, analysis: AIEmotionAnalysisResult) async throws {
        guard let user = try await getUserById(userId) else {
            throw WellnessError.userNotFound
        }
        
        if let lastEmotion = user.emotions.last {
            lastEmotion.aiAnalysis = analysis
        }
        
        do {
            try modelContext.save()
        } catch {
            throw WellnessError.updateFailed("Failed to update emotion analysis: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sleep Data Management
    func addSleepData(userId: UUID, bedTime: Date, wakeTime: Date, quality: SleepQuality, notes: String?) async throws {
        guard let user = try await getUserById(userId) else {
            throw WellnessError.userNotFound
        }
        
        let sleepData = SleepData(
            bedTime: bedTime,
            wakeTime: wakeTime,
            quality: quality,
            notes: notes
        )
        
        user.sleepData.append(sleepData)
        
        // Award experience points
        let experiencePoints = calculateSleepExperience(hours: sleepData.totalHours, quality: quality)
        user.pantherProgress.addExperience(points: experiencePoints)
        user.pantherProgress.updateDailyActivity()
        
        do {
            try modelContext.save()
        } catch {
            throw WellnessError.creationFailed("Failed to add sleep data: \(error.localizedDescription)")
        }
    }
    
    func getSleepData(userId: UUID, fromDate: Date? = nil, toDate: Date? = nil) async throws -> [SleepData] {
        guard let user = try await getUserById(userId) else {
            return []
        }
        
        var sleepData = user.sleepData
        
        if let fromDate = fromDate {
            sleepData = sleepData.filter { $0.date >= fromDate }
        }
        
        if let toDate = toDate {
            sleepData = sleepData.filter { $0.date <= toDate }
        }
        
        return sleepData.sorted { $0.date > $1.date }
    }
    
    // MARK: - Progress and Stats
    func getUserProgress(userId: UUID) async throws -> WellnessProgressSummary {
        guard let user = try await getUserById(userId) else {
            throw WellnessError.userNotFound
        }
        
        let physicalStats = calculatePhysicalStats(for: user)
        let emotionalStats = calculateEmotionalStats(for: user)
        let sleepStats = calculateSleepStats(for: user)
        let pantherStats = calculatePantherStats(for: user)
        let overallScore = calculateOverallScore(physical: physicalStats, emotional: emotionalStats, sleep: sleepStats)
        
        return WellnessProgressSummary(
            user: user,
            physicalStats: physicalStats,
            emotionalStats: emotionalStats,
            sleepStats: sleepStats,
            pantherStats: pantherStats,
            overallScore: overallScore,
            lastUpdated: Date()
        )
    }
    
    func getWeeklyStats(userId: UUID) async throws -> WeeklyStats {
        guard let user = try await getUserById(userId) else {
            throw WellnessError.userNotFound
        }
        
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
        
        // Get activities for this week
        let weeklyActivities = try await getPhysicalActivities(
            userId: userId,
            fromDate: weekStart,
            toDate: weekEnd
        )
        
        // Get emotions for this week
        let weeklyEmotions = user.emotions.filter { $0.date >= weekStart && $0.date <= weekEnd }
        
        // Get sleep data for this week
        let weeklySleep = try await getSleepData(
            userId: userId,
            fromDate: weekStart,
            toDate: weekEnd
        )
        
        let activitiesCompleted = weeklyActivities.count
        let emotionsTracked = weeklyEmotions.count
        let sleepHours = weeklySleep.reduce(0) { $0 + $1.totalHours }
        let averageSleep = weeklySleep.isEmpty ? 0 : sleepHours / Double(weeklySleep.count)
        
        let sleepQuality = calculateAverageSleepQuality(sleepData: weeklySleep)
        let experienceEarned = calculateWeeklyExperience(
            activities: weeklyActivities,
            emotions: weeklyEmotions,
            sleepData: weeklySleep
        )
        
        let goalsAchieved = calculateAchievedGoals(
            user: user,
            activities: weeklyActivities,
            emotions: weeklyEmotions
        )
        
        return WeeklyStats(
            weekStart: weekStart,
            weekEnd: weekEnd,
            activitiesCompleted: activitiesCompleted,
            emotionsTracked: emotionsTracked,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            experienceEarned: experienceEarned,
            goalsAchieved: goalsAchieved
        )
    }
    
    // MARK: - Private Helper Methods
    private func updateActivityDays(physicalData: PhysicalData) {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        let uniqueDays = Set(physicalData.activities
            .filter { $0.date >= startOfWeek }
            .map { calendar.startOfDay(for: $0.date) })
        
        physicalData.activityDays = uniqueDays.count
    }
    
    private func calculateActivityExperience(type: ActivityType, duration: Int) -> Int {
        let baseExperience = 10
        let durationBonus = min(duration / 10, 5) // Max 5 bonus points for duration
        let typeMultiplier: Int
        
        switch type {
        case .running, .cycling, .swimming:
            typeMultiplier = 2
        case .gym, .sports:
            typeMultiplier = 1
        case .yoga, .walking:
            typeMultiplier = 1
        case .other:
            typeMultiplier = 1
        }
        
        return (baseExperience + durationBonus) * typeMultiplier
    }
    
    private func calculateEmotionExperience(emotion: EmotionType, responseCount: Int) -> Int {
        let baseExperience = 15
        let responseBonus = min(responseCount * 2, 10) // Max 10 bonus points
        
        // Bonus for positive emotions
        let emotionBonus: Int
        switch emotion {
        case .happy, .grateful, .peaceful, .excited:
            emotionBonus = 5
        case .sad, .anxious, .angry, .stressed, .tired, .confused:
            emotionBonus = 3
        }
        
        return baseExperience + responseBonus + emotionBonus
    }
    
    private func calculateSleepExperience(hours: Double, quality: SleepQuality) -> Int {
        let baseExperience = 10
        
        // Bonus for optimal sleep duration (7-9 hours)
        let durationBonus: Int
        if hours >= 7 && hours <= 9 {
            durationBonus = 5
        } else if hours >= 6 && hours < 7 {
            durationBonus = 2
        } else {
            durationBonus = 0
        }
        
        // Bonus for sleep quality
        let qualityBonus: Int
        switch quality {
        case .excellent:
            qualityBonus = 5
        case .good:
            qualityBonus = 3
        case .fair:
            qualityBonus = 1
        case .poor:
            qualityBonus = 0
        }
        
        return baseExperience + durationBonus + qualityBonus
    }
    
    private func calculatePhysicalStats(for user: User) -> WellnessProgressSummary.PhysicalStats {
        guard let physicalData = user.physicalData else {
            return WellnessProgressSummary.PhysicalStats(
                currentWeight: 0,
                bmi: 0,
                weeklyActivityDays: 0,
                weeklyGoal: 0,
                totalActivities: 0,
                caloriesBurnedThisWeek: 0
            )
        }
        
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let thisWeekActivities = physicalData.activities.filter { $0.date >= startOfWeek }
        let caloriesBurnedThisWeek = thisWeekActivities.compactMap { $0.caloriesBurned }.reduce(0, +)
        
        return WellnessProgressSummary.PhysicalStats(
            currentWeight: physicalData.weight,
            bmi: physicalData.bmi,
            weeklyActivityDays: physicalData.activityDays,
            weeklyGoal: physicalData.weeklyGoal,
            totalActivities: physicalData.activities.count,
            caloriesBurnedThisWeek: caloriesBurnedThisWeek
        )
    }
    
    private func calculateEmotionalStats(for user: User) -> WellnessProgressSummary.EmotionalStats {
        let moodTrend = user.moodJar?.moodTrend ?? []
        let lastAnalysis = user.emotions.last?.aiAnalysis
        
        return WellnessProgressSummary.EmotionalStats(
            totalEmotionEntries: user.emotions.count,
            currentMood: user.moodJar?.currentMood,
            moodTrend: moodTrend,
            lastAnalysis: lastAnalysis,
            consecutiveDaysTracked: user.pantherProgress.consecutiveDays
        )
    }
    
    private func calculateSleepStats(for user: User) -> WellnessProgressSummary.SleepStats {
        let lastWeekSleep = user.sleepData.suffix(7)
        let averageHours = lastWeekSleep.isEmpty ? 0 : lastWeekSleep.reduce(0) { $0 + $1.totalHours } / Double(lastWeekSleep.count)
        let sleepEfficiency = lastWeekSleep.isEmpty ? 0 : lastWeekSleep.reduce(0) { $0 + $1.sleepEfficiency } / Double(lastWeekSleep.count)
        
        return WellnessProgressSummary.SleepStats(
            averageHours: averageHours,
            averageQuality: calculateAverageSleepQuality(sleepData: Array(lastWeekSleep)),
            lastWeekEntries: lastWeekSleep.count,
            sleepEfficiency: sleepEfficiency
        )
    }
    
    private func calculatePantherStats(for user: User) -> WellnessProgressSummary.PantherStats {
        return WellnessProgressSummary.PantherStats(
            currentLevel: user.pantherProgress.currentLevel,
            experiencePoints: user.pantherProgress.experiencePoints,
            progressToNextLevel: user.pantherProgress.progressPercentage,
            consecutiveDays: user.pantherProgress.consecutiveDays,
            unlockedFeatures: user.pantherProgress.unlockedFeatures
        )
    }
    
    private func calculateOverallScore(physical: WellnessProgressSummary.PhysicalStats, emotional: WellnessProgressSummary.EmotionalStats, sleep: WellnessProgressSummary.SleepStats) -> Double {
        let physicalScore = min(Double(physical.weeklyActivityDays) / Double(physical.weeklyGoal), 1.0) * 0.4
        let emotionalScore = emotional.totalEmotionEntries > 0 ? 0.3 : 0.0
        let sleepScore = sleep.averageHours >= 7 && sleep.averageHours <= 9 ? 0.3 : (sleep.averageHours > 0 ? 0.15 : 0.0)
        
        return physicalScore + emotionalScore + sleepScore
    }
    
    private func calculateAverageSleepQuality(sleepData: [SleepData]) -> SleepQuality {
        guard !sleepData.isEmpty else { return .fair }
        
        let qualityValues = sleepData.map { sleep in
            switch sleep.quality {
            case .excellent: return 4
            case .good: return 3
            case .fair: return 2
            case .poor: return 1
            }
        }
        
        let average = Double(qualityValues.reduce(0, +)) / Double(qualityValues.count)
        
        switch average {
        case 3.5...4: return .excellent
        case 2.5..<3.5: return .good
        case 1.5..<2.5: return .fair
        default: return .poor
        }
    }
    
    private func calculateWeeklyExperience(activities: [PhysicalActivity], emotions: [EmotionData], sleepData: [SleepData]) -> Int {
        let activityExperience = activities.reduce(0) { total, activity in
            total + calculateActivityExperience(type: activity.type, duration: activity.duration)
        }
        
        let emotionExperience = emotions.reduce(0) { total, emotion in
            total + calculateEmotionExperience(emotion: emotion.emotion, responseCount: emotion.responses.count)
        }
        
        let sleepExperience = sleepData.reduce(0) { total, sleep in
            total + calculateSleepExperience(hours: sleep.totalHours, quality: sleep.quality)
        }
        
        return activityExperience + emotionExperience + sleepExperience
    }
    
    private func calculateAchievedGoals(user: User, activities: [PhysicalActivity], emotions: [EmotionData]) -> [String] {
        var goals: [String] = []
        
        // Physical activity goal
        if let physicalData = user.physicalData {
            if activities.count >= physicalData.weeklyGoal {
                goals.append("Meta de actividad semanal")
            }
        }
        
        // Emotion tracking goal
        if emotions.count >= 3 {
            goals.append("Seguimiento emocional regular")
        }
        
        // Panther care goal
        if user.pantherProgress.consecutiveDays >= 7 {
            goals.append("Cuidado continuo de la pantera")
        }
        
        return goals
    }
}

// MARK: - Wellness Error
enum WellnessError: Error, LocalizedError {
    case userNotFound
    case physicalDataNotFound
    case creationFailed(String)
    case updateFailed(String)
    case fetchFailed(String)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Usuario no encontrado"
        case .physicalDataNotFound:
            return "Datos físicos no encontrados"
        case .creationFailed(let message):
            return "Error al crear: \(message)"
        case .updateFailed(let message):
            return "Error al actualizar: \(message)"
        case .fetchFailed(let message):
            return "Error al obtener datos: \(message)"
        case .invalidData(let message):
            return "Datos inválidos: \(message)"
        }
    }
}
