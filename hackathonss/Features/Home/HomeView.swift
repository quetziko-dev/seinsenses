import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var currentUser: User?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    welcomeSection
                    
                    // Panther Status
                    if let user = currentUser {
                        pantherStatusSection(user: user)
                    }
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Today's Overview
                    todayOverviewSection
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle(currentUser != nil ? "Bienvenido, \(currentUser!.displayName)" : "Bienvenido")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileEditView(user: currentUser)) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.themeTeal)
                    }
                }
            }
            .onAppear {
                setupCurrentUser()
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Usar displayName del usuario si está disponible
            if let user = currentUser {
                Text("¡Hola de nuevo, \(user.displayName)!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.themePrimaryDarkGreen)
            } else {
                Text("¡Hola de nuevo!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.themePrimaryDarkGreen)
            }
            
            Text("Tu pantera está lista para acompañarte en tu viaje de bienestar")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func pantherStatusSection(user: User) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(user.pantherProgress.currentLevel.displayName)
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Nivel \(user.pantherProgress.currentLevel == .cub ? 1 : user.pantherProgress.currentLevel == .young ? 2 : 3)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Panther Avatar (placeholder)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.themeTeal)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Experiencia")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(user.pantherProgress.progressPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.themePrimaryDarkGreen)
                }
                
                ProgressView(value: user.pantherProgress.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .themeTeal))
                    .scaleEffect(y: 1.5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones Rápidas")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Estado de Ánimo",
                    icon: "heart.fill",
                    color: .themeTeal,
                    destination: AnyView(EmotionFlowView())
                )
                
                QuickActionCard(
                    title: "Plan IA Personalizado",
                    icon: "sparkles",
                    color: .themeTeal,
                    destination: AnyView(AIPlansView())
                )
                
                QuickActionCard(
                    title: "Actividad Física",
                    icon: "figure.walk",
                    color: .themePrimaryDarkGreen,
                    destination: AnyView(PhysicalDetailView())
                )
                
                QuickActionCard(
                    title: "Registro de Sueño",
                    icon: "moon.fill",
                    color: .themeLavender,
                    destination: AnyView(SleepTrackingView())
                )
                
                QuickActionCard(
                    title: "Meditación",
                    icon: "brain.head.profile",
                    color: .themeDeepBlue,
                    destination: AnyView(MeditationView())
                )
            }
        }
    }
    
    private var todayOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resumen de Hoy")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 8) {
                OverviewRow(
                    title: "Días consecutivos",
                    value: "\(currentUser?.pantherProgress.consecutiveDays ?? 0)",
                    icon: "calendar",
                    color: .themeTeal
                )
                
                OverviewRow(
                    title: "Actividades completadas",
                    value: "\(currentUser?.pantherProgress.totalWellnessActivities ?? 0)",
                    icon: "checkmark.circle.fill",
                    color: .themePrimaryDarkGreen
                )
                
                OverviewRow(
                    title: "Estado emocional",
                    value: currentUser?.moodJar?.currentMood?.rawValue ?? "No registrado",
                    icon: "heart.fill",
                    color: .themeLavender
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
    }
}

struct QuickActionCard<Destination: View>: View {
    let title: String
    let icon: String
    let color: Color
    let destination: Destination
    @State private var isShowingDestination = false
    
    var body: some View {
        Button(action: {
            isShowingDestination = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .navigationDestination(isPresented: $isShowingDestination) {
            destination
        }
    }
}

struct OverviewRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [User.self, PantherProgress.self, MoodJar.self], inMemory: true)
}
