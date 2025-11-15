import Foundation
import SwiftUI
import SwiftData

/// SessionManager: Servicio centralizado para manejar la sesión del usuario
/// Responsable de logout limpio y limpieza de datos entre cuentas
@MainActor
final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var currentUser: User?
    private var modelContext: ModelContext?
    
    private init() {}
    
    /// Configura el contexto de modelo para operaciones de datos
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    /// Realiza un logout limpio, borrando todos los datos del usuario anterior
    func performCleanLogout() {
        print("🔴 SessionManager: Iniciando logout limpio...")
        
        // 1. Limpiar datos persistidos en SwiftData
        clearAllUserData()
        
        // 2. Limpiar estado en memoria
        currentUser = nil
        
        // 3. Limpiar UserDefaults del usuario
        clearUserDefaults()
        
        // 4. Notificar al AuthenticationManager
        AuthenticationManager.shared.logout()
        
        print("✅ SessionManager: Logout limpio completado")
    }
    
    // MARK: - Data Cleanup
    
    /// Elimina TODOS los datos de usuario de SwiftData
    private func clearAllUserData() {
        guard let context = modelContext else {
            print("⚠️ SessionManager: No hay contexto de modelo configurado")
            return
        }
        
        print("🗑️ SessionManager: Limpiando datos de SwiftData...")
        
        do {
            // Limpiar avatares antes de eliminar usuarios
            let descriptor = FetchDescriptor<User>()
            let users = try context.fetch(descriptor)
            for user in users {
                user.deleteAvatarImage()
            }
            print("  ✓ Eliminadas \(users.count) fotos de avatar")
            
            // Eliminar todos los usuarios y sus datos relacionados
            try deleteAll(User.self, from: context)
            try deleteAll(PhysicalData.self, from: context)
            try deleteAll(PhysicalActivity.self, from: context)
            try deleteAll(PhysicalProfile.self, from: context)
            try deleteAll(GeneratedPlans.self, from: context)
            try deleteAll(JournalEntry.self, from: context)
            try deleteAll(SocialPlan.self, from: context)
            try deleteAll(SleepData.self, from: context)
            try deleteAll(EmotionData.self, from: context)
            try deleteAll(EmotionResponse.self, from: context)
            try deleteAll(MoodJar.self, from: context)
            try deleteAll(MoodMarble.self, from: context)
            try deleteAll(PantherProgress.self, from: context)
            try deleteAll(PantherEvolution.self, from: context)
            
            // Guardar cambios
            try context.save()
            
            print("✅ SessionManager: Todos los datos de SwiftData eliminados")
        } catch {
            print("❌ SessionManager: Error al limpiar datos: \(error.localizedDescription)")
        }
    }
    
    /// Método genérico para eliminar todas las entidades de un tipo
    private func deleteAll<T: PersistentModel>(_ type: T.Type, from context: ModelContext) throws {
        let descriptor = FetchDescriptor<T>()
        let items = try context.fetch(descriptor)
        
        for item in items {
            context.delete(item)
        }
        
        print("  ✓ Eliminados \(items.count) registros de \(String(describing: type))")
    }
    
    /// Limpia las claves de UserDefaults relacionadas con el usuario
    private func clearUserDefaults() {
        print("🗑️ SessionManager: Limpiando UserDefaults...")
        
        // Limpiar nombre registrado (ya lo hace AuthenticationManager, pero lo aseguramos)
        UserDefaults.standard.removeObject(forKey: "registeredUserName")
        
        // Agregar aquí cualquier otra clave de UserDefaults que guardes
        // Ejemplos:
        // UserDefaults.standard.removeObject(forKey: "lastSyncDate")
        // UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        
        print("✅ SessionManager: UserDefaults limpiados")
    }
}

// MARK: - ModelContext Extension
extension ModelContext {
    /// Limpia todos los datos de usuario de forma segura
    @MainActor
    func clearAllUserData() {
        print("🗑️ ModelContext: Iniciando limpieza de datos...")
        
        do {
            // Helper function para borrar todas las entidades de un tipo
            func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
                let descriptor = FetchDescriptor<T>()
                let items = try fetch(descriptor)
                for item in items {
                    delete(item)
                }
                print("  ✓ Eliminados \(items.count) registros de \(String(describing: type))")
            }
            
            // Eliminar en orden para respetar relaciones
            try deleteAll(EmotionResponse.self)
            try deleteAll(EmotionData.self)
            try deleteAll(MoodMarble.self)
            try deleteAll(MoodJar.self)
            try deleteAll(PhysicalActivity.self)
            try deleteAll(SleepData.self)
            try deleteAll(PhysicalData.self)
            try deleteAll(PantherEvolution.self)
            try deleteAll(PantherProgress.self)
            try deleteAll(User.self)
            
            // Guardar cambios
            try save()
            
            print("✅ ModelContext: Limpieza completada exitosamente")
        } catch {
            print("❌ ModelContext: Error al limpiar datos: \(error.localizedDescription)")
        }
    }
}
