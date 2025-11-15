import SwiftUI
import SwiftData

@main
struct WellnessPantherApp: App {
    
    let modelContainer: ModelContainer
    @State private var isAuthenticated = UserDefaults.standard.bool(forKey: "isUserAuthenticated")
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: User.self,
                PhysicalData.self,
                PhysicalActivity.self,
                PhysicalProfile.self,
                GeneratedPlans.self,
                JournalEntry.self,
                SocialPlan.self,
                SleepData.self,
                EmotionData.self,
                EmotionResponse.self,
                MoodJar.self,
                MoodMarble.self,
                PantherProgress.self,
                PantherEvolution.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView()
                    .modelContainer(modelContainer)
                    .onAppear {
                        // Configurar SessionManager con el contexto de modelo
                        Task { @MainActor in
                            SessionManager.shared.configure(with: modelContainer.mainContext)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDidLogout"))) { _ in
                        isAuthenticated = false
                    }
            } else {
                AuthenticationView()
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDidAuthenticate"))) { _ in
                        isAuthenticated = true
                    }
            }
        }
    }
}
