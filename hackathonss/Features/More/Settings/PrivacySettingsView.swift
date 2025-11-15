import SwiftUI
import SwiftData

struct PrivacySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("allowAnonymousData") private var allowAnonymousData = false
    @State private var showingDeleteAlert = false
    @State private var showingDeletedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Protección de tus datos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Tu privacidad es nuestra prioridad. Controla cómo se usan tus datos")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Anonymous Data Toggle
                VStack(spacing: 16) {
                    Toggle(isOn: $allowAnonymousData) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.themeTeal)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Datos anónimos")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text("Ayúdanos a mejorar enviando datos anónimos de uso")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(.themeTeal)
                    
                    Text("Los datos anónimos nos ayudan a entender cómo se usa la app para mejorarla. No se comparte información personal.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Data Management
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gestión de datos")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    VStack(spacing: 12) {
                        DataInfoRow(
                            icon: "person.fill",
                            title: "Perfil y preferencias",
                            description: "Apodo, foto, configuraciones"
                        )
                        
                        Divider()
                        
                        DataInfoRow(
                            icon: "heart.fill",
                            title: "Datos emocionales",
                            description: "Registro de emociones y reflexiones"
                        )
                        
                        Divider()
                        
                        DataInfoRow(
                            icon: "figure.walk",
                            title: "Datos físicos",
                            description: "Rutinas, planes de alimentación"
                        )
                        
                        Divider()
                        
                        DataInfoRow(
                            icon: "person.2.fill",
                            title: "Datos sociales",
                            description: "Planes, misiones completadas"
                        )
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Delete Data Button
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Borrar mis datos locales")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Info Footer
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2)
                        .foregroundColor(.themeTeal)
                    
                    Text("Tus datos están seguros")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("Toda tu información se almacena de forma segura en tu dispositivo y nunca se comparte sin tu consentimiento")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.themeTeal.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Privacidad")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Borrar todos los datos", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Borrar", role: .destructive) {
                deleteAllLocalData()
            }
        } message: {
            Text("Esta acción eliminará:\n\n• Perfil y foto\n• Historial emocional\n• Planes de ejercicio y dieta\n• Entradas de diario\n• Misiones y planes sociales\n\n¿Estás seguro?")
        }
        .alert("Datos eliminados", isPresented: $showingDeletedAlert) {
            Button("OK") { }
        } message: {
            Text("Todos tus datos locales han sido eliminados exitosamente")
        }
    }
    
    private func deleteAllLocalData() {
        do {
            // Clear all SwiftData models
            try modelContext.delete(model: User.self)
            try modelContext.delete(model: PhysicalData.self)
            try modelContext.delete(model: PhysicalActivity.self)
            try modelContext.delete(model: PhysicalProfile.self)
            try modelContext.delete(model: GeneratedPlans.self)
            try modelContext.delete(model: JournalEntry.self)
            try modelContext.delete(model: SocialPlan.self)
            try modelContext.delete(model: SleepData.self)
            try modelContext.delete(model: EmotionData.self)
            try modelContext.delete(model: EmotionResponse.self)
            try modelContext.delete(model: MoodJar.self)
            try modelContext.delete(model: MoodMarble.self)
            try modelContext.delete(model: PantherProgress.self)
            try modelContext.delete(model: PantherEvolution.self)
            
            try modelContext.save()
            
            // Clear UserDefaults (keep only app settings)
            let keysToKeep = ["notificationsEnabled", "waterReminder", "movementReminder", "breathingReminder", "allowAnonymousData", "selectedLanguage"]
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            
            dictionary.keys.forEach { key in
                if !keysToKeep.contains(key) && !key.hasPrefix("Apple") && !key.hasPrefix("NS") {
                    defaults.removeObject(forKey: key)
                }
            }
            
            showingDeletedAlert = true
            print("✅ Datos locales eliminados exitosamente")
        } catch {
            print("❌ Error al eliminar datos: \(error)")
        }
    }
}

struct DataInfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.themeTeal)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        PrivacySettingsView()
    }
}
