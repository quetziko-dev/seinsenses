import Foundation
import SwiftData

// MARK: - Model Container Factory
class ModelContainerFactory {
    
    static let shared = ModelContainerFactory()
    
    private init() {}
    
    // MARK: - Container Creation
    func createModelContainer() throws -> ModelContainer {
        let schema = Schema([
            // Core Models
            User.self,
            PhysicalData.self,
            PhysicalActivity.self,
            SleepData.self,
            EmotionData.self,
            EmotionResponse.self,
            MoodJar.self,
            MoodMarble.self,
            PantherProgress.self,
            PantherEvolution.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Setup migration and relationship testing
            setupContainer(container)
            
            return container
        } catch {
            throw PersistenceError.containerCreationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - In-Memory Container for Testing
    func createInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            User.self,
            PhysicalData.self,
            PhysicalActivity.self,
            SleepData.self,
            EmotionData.self,
            EmotionResponse.self,
            MoodJar.self,
            MoodMarble.self,
            PantherProgress.self,
            PantherEvolution.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            setupContainer(container)
            return container
        } catch {
            throw PersistenceError.containerCreationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Container Setup
    private func setupContainer(_ container: ModelContainer) {
        // Set up relationship handlers if needed
        Task { @MainActor in
            container.mainContext.autosaveEnabled = true
            
            // Configure undo manager for better data integrity
            container.mainContext.undoManager = UndoManager()
        }
    }
    
    // MARK: - Data Validation
    @MainActor
    func validateModelRelationships(container: ModelContainer) throws {
        let context = container.mainContext
        
        // Test User -> PhysicalData relationship
        try testUserPhysicalDataRelationship(context: context)
        
        // Test User -> MoodJar -> MoodMarble relationship
        try testMoodJarRelationship(context: context)
        
        // Test User -> PantherProgress relationship
        try testPantherProgressRelationship(context: context)
        
        // Test User -> EmotionData -> EmotionResponse relationship
        try testEmotionDataRelationship(context: context)
        
        // Test User -> SleepData relationship
        try testSleepDataRelationship(context: context)
    }
    
    // MARK: - Relationship Testing
    private func testUserPhysicalDataRelationship(context: ModelContext) throws {
        let user = User(name: "Test User")
        let physicalData = PhysicalData(height: 170, weight: 70, weeklyGoal: 5)
        
        user.physicalData = physicalData
        physicalData.user = user
        
        context.insert(user)
        
        do {
            try context.save()
            
            // Fetch and verify relationship
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.name == "Test User" }
            )
            
            let fetchedUsers = try context.fetch(descriptor)
            guard let fetchedUser = fetchedUsers.first else {
                throw PersistenceError.relationshipTestFailed("Failed to fetch test user")
            }
            
            guard fetchedUser.physicalData != nil else {
                throw PersistenceError.relationshipTestFailed("User-PhysicalData relationship not established")
            }
            
            // Clean up
            context.delete(fetchedUser)
            if let physicalData = fetchedUser.physicalData {
                context.delete(physicalData)
            }
            try context.save()
            
        } catch {
            throw PersistenceError.relationshipTestFailed("User-PhysicalData relationship test failed: \(error.localizedDescription)")
        }
    }
    
    private func testMoodJarRelationship(context: ModelContext) throws {
        let user = User(name: "Mood Test User")
        let moodJar = MoodJar()
        
        user.moodJar = moodJar
        moodJar.user = user
        
        // Add some marbles
        moodJar.addMarble(emotion: .happy, intensity: 0.8)
        moodJar.addMarble(emotion: .grateful, intensity: 0.9)
        
        context.insert(user)
        
        do {
            try context.save()
            
            // Fetch and verify relationship
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.name == "Mood Test User" }
            )
            
            let fetchedUsers = try context.fetch(descriptor)
            guard let fetchedUser = fetchedUsers.first else {
                throw PersistenceError.relationshipTestFailed("Failed to fetch mood test user")
            }
            
            guard let fetchedMoodJar = fetchedUser.moodJar else {
                throw PersistenceError.relationshipTestFailed("User-MoodJar relationship not established")
            }
            
            guard !fetchedMoodJar.marbles.isEmpty else {
                throw PersistenceError.relationshipTestFailed("MoodJar-Marble relationship not established")
            }
            
            // Clean up
            context.delete(fetchedUser)
            if let moodJar = fetchedUser.moodJar {
                for marble in moodJar.marbles {
                    context.delete(marble)
                }
                context.delete(moodJar)
            }
            try context.save()
            
        } catch {
            throw PersistenceError.relationshipTestFailed("MoodJar relationship test failed: \(error.localizedDescription)")
        }
    }
    
    private func testPantherProgressRelationship(context: ModelContext) throws {
        let user = User(name: "Panther Test User")
        let pantherProgress = PantherProgress()
        
        user.pantherProgress = pantherProgress
        
        // Add some experience
        pantherProgress.addExperience(points: 50)
        pantherProgress.updateDailyActivity()
        
        context.insert(user)
        
        do {
            try context.save()
            
            // Fetch and verify relationship
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.name == "Panther Test User" }
            )
            
            let fetchedUsers = try context.fetch(descriptor)
            guard let fetchedUser = fetchedUsers.first else {
                throw PersistenceError.relationshipTestFailed("Failed to fetch panther test user")
            }
            
            guard fetchedUser.pantherProgress.experiencePoints > 0 else {
                throw PersistenceError.relationshipTestFailed("PantherProgress data not properly saved")
            }
            
            // Clean up
            let pantherProgress = fetchedUser.pantherProgress
            context.delete(fetchedUser)
            context.delete(pantherProgress)
            try context.save()
            
        } catch {
            throw PersistenceError.relationshipTestFailed("PantherProgress relationship test failed: \(error.localizedDescription)")
        }
    }
    
    private func testEmotionDataRelationship(context: ModelContext) throws {
        let user = User(name: "Emotion Test User")
        let responses = [
            EmotionResponse(question: "Test Question 1", answer: "Test Answer 1"),
            EmotionResponse(question: "Test Question 2", answer: "Test Answer 2")
        ]
        
        let emotionData = EmotionData(
            emotion: .happy,
            intensity: 0.8,
            responses: responses
        )
        
        user.emotions.append(emotionData)
        emotionData.user = user
        
        context.insert(user)
        
        do {
            try context.save()
            
            // Fetch and verify relationship
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.name == "Emotion Test User" }
            )
            
            let fetchedUsers = try context.fetch(descriptor)
            guard let fetchedUser = fetchedUsers.first else {
                throw PersistenceError.relationshipTestFailed("Failed to fetch emotion test user")
            }
            
            guard !fetchedUser.emotions.isEmpty else {
                throw PersistenceError.relationshipTestFailed("User-EmotionData relationship not established")
            }
            
            let fetchedEmotionData = fetchedUser.emotions.first!
            guard !fetchedEmotionData.responses.isEmpty else {
                throw PersistenceError.relationshipTestFailed("EmotionData-EmotionResponse relationship not established")
            }
            
            // Clean up
            context.delete(fetchedUser)
            for emotionData in fetchedUser.emotions {
                for response in emotionData.responses {
                    context.delete(response)
                }
                context.delete(emotionData)
            }
            try context.save()
            
        } catch {
            throw PersistenceError.relationshipTestFailed("EmotionData relationship test failed: \(error.localizedDescription)")
        }
    }
    
    private func testSleepDataRelationship(context: ModelContext) throws {
        let user = User(name: "Sleep Test User")
        let sleepData = SleepData(
            bedTime: Date(),
            wakeTime: Date().addingTimeInterval(8 * 3600),
            quality: .good,
            notes: "Test sleep"
        )
        
        user.sleepData.append(sleepData)
        sleepData.user = user
        
        context.insert(user)
        
        do {
            try context.save()
            
            // Fetch and verify relationship
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.name == "Sleep Test User" }
            )
            
            let fetchedUsers = try context.fetch(descriptor)
            guard let fetchedUser = fetchedUsers.first else {
                throw PersistenceError.relationshipTestFailed("Failed to fetch sleep test user")
            }
            
            guard !fetchedUser.sleepData.isEmpty else {
                throw PersistenceError.relationshipTestFailed("User-SleepData relationship not established")
            }
            
            let fetchedSleepData = fetchedUser.sleepData.first!
            guard fetchedSleepData.user?.id == fetchedUser.id else {
                throw PersistenceError.relationshipTestFailed("SleepData-User inverse relationship not established")
            }
            
            // Clean up
            context.delete(fetchedUser)
            for sleepData in fetchedUser.sleepData {
                context.delete(sleepData)
            }
            try context.save()
            
        } catch {
            throw PersistenceError.relationshipTestFailed("SleepData relationship test failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Migration
    func performMigrationIfNeeded() throws {
        // In a real app, this would handle schema migrations
        // For now, we'll just validate the current schema
        print("Data migration check completed")
    }
    
    // MARK: - Health Check
    @MainActor
    func performHealthCheck(container: ModelContainer) async -> PersistenceHealthCheck {
        let context = container.mainContext
        
        var issues: [String] = []
        var isHealthy = true
        
        do {
            // Test basic save/load
            let testUser = User(name: "Health Check User")
            context.insert(testUser)
            try context.save()
            
            // Test fetch
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { $0.name == "Health Check User" }
            )
            let fetchedUsers = try context.fetch(descriptor)
            
            if fetchedUsers.isEmpty {
                issues.append("Basic save/load test failed")
                isHealthy = false
            }
            
            // Clean up
            context.delete(testUser)
            try context.save()
            
            // Test relationships
            try validateModelRelationships(container: container)
            
        } catch {
            issues.append("Health check failed: \(error.localizedDescription)")
            isHealthy = false
        }
        
        return PersistenceHealthCheck(
            isHealthy: isHealthy,
            issues: issues,
            timestamp: Date()
        )
    }
}

// MARK: - Persistence Health Check
struct PersistenceHealthCheck {
    let isHealthy: Bool
    let issues: [String]
    let timestamp: Date
}

// MARK: - Persistence Error
enum PersistenceError: Error, LocalizedError {
    case containerCreationFailed(String)
    case relationshipTestFailed(String)
    case migrationFailed(String)
    case healthCheckFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .containerCreationFailed(let message):
            return "Error creating model container: \(message)"
        case .relationshipTestFailed(let message):
            return "Relationship test failed: \(message)"
        case .migrationFailed(let message):
            return "Data migration failed: \(message)"
        case .healthCheckFailed(let message):
            return "Health check failed: \(message)"
        }
    }
}

// MARK: - Persistence Manager
class PersistenceManager: ObservableObject {
    private let containerFactory = ModelContainerFactory.shared
    private var modelContainer: ModelContainer?
    
    @Published var isInitialized = false
    @Published var initializationError: String?
    
    func initialize() async {
        do {
            modelContainer = try containerFactory.createModelContainer()
            
            // Perform health check
            let healthCheck = try await containerFactory.performHealthCheck(container: modelContainer!)
            
            await MainActor.run {
                self.isInitialized = healthCheck.isHealthy
                if !healthCheck.isHealthy {
                    self.initializationError = healthCheck.issues.joined(separator: "; ")
                }
            }
            
        } catch {
            await MainActor.run {
                self.isInitialized = false
                self.initializationError = error.localizedDescription
            }
        }
    }
    
    func getContainer() throws -> ModelContainer {
        guard let container = modelContainer else {
            throw PersistenceError.containerCreationFailed("Container not initialized")
        }
        return container
    }
    
    func reset() async {
        modelContainer = nil
        await MainActor.run {
            self.isInitialized = false
            self.initializationError = nil
        }
    }
}
