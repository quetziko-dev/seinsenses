import SwiftUI
import SwiftData

struct PhysicalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var currentUser: User?
    @State private var isShowingDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full background extending to edges
                Color.themeLightAqua
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let user = currentUser, let physicalData = user.physicalData {
                            physicalStatsSection(physicalData: physicalData)
                            recentActivitiesSection(user: user)
                            weeklyProgressSection(physicalData: physicalData)
                        } else {
                            setupPhysicalDataPrompt
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Bienestar Físico")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        isShowingDetail = true
                    }
                    .foregroundColor(.themeTeal)
                }
            }
            .onAppear {
                setupCurrentUser()
            }
            .navigationDestination(isPresented: $isShowingDetail) {
                PhysicalDetailView()
            }
        }
    }
    
    private func physicalStatsSection(physicalData: PhysicalData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas Físicas")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Altura",
                    value: "\(String(format: "%.1f", physicalData.height)) cm",
                    icon: "ruler",
                    color: .themeTeal
                )
                
                StatRow(
                    title: "Peso",
                    value: "\(String(format: "%.1f", physicalData.weight)) kg",
                    icon: "scalemass",
                    color: .themeTeal
                )
                
                StatRow(
                    title: "IMC",
                    value: String(format: "%.1f", physicalData.bmi),
                    icon: "heart.text.square",
                    color: physicalData.bmi < 18.5 || physicalData.bmi > 25 ? .themeDeepBlue : .themePrimaryDarkGreen
                )
                
                StatRow(
                    title: "Días activos esta semana",
                    value: "\(physicalData.activityDays)/\(physicalData.weeklyGoal)",
                    icon: "calendar.badge.plus",
                    color: .themeLavender
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .themeTeal.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func recentActivitiesSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividades Recientes")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            if let physicalData = user.physicalData, !physicalData.activities.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(physicalData.activities.sorted { $0.date > $1.date }.prefix(5), id: \.id) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            } else {
                Text("No hay actividades registradas")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .themeTeal.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func weeklyProgressSection(physicalData: PhysicalData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso Semanal")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Meta semanal")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(physicalData.activityDays)/\(physicalData.weeklyGoal) días")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.themePrimaryDarkGreen)
                }
                
                ProgressView(value: Double(physicalData.activityDays), total: Double(physicalData.weeklyGoal))
                    .progressViewStyle(LinearProgressViewStyle(tint: .themeTeal))
                    .scaleEffect(y: 1.5)
                
                if physicalData.activityDays >= physicalData.weeklyGoal {
                    Text("¡Meta alcanzada! 🎉")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.themePrimaryDarkGreen)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .themeTeal.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var setupPhysicalDataPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk")
                .font(.system(size: 60))
                .foregroundColor(.themeTeal)
            
            Text("Configura tu perfil físico")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("Registra tu altura, peso y metas de actividad para comenzar tu viaje de bienestar físico")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Configurar ahora") {
                isShowingDetail = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .themeTeal.opacity(0.08), radius: 8, x: 0, y: 4)
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

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
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

struct ActivityRow: View {
    let activity: PhysicalActivity
    
    var body: some View {
        HStack {
            Image(systemName: activity.iconName)
                .foregroundColor(.themeTeal)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.type.rawValue.capitalized)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(activity.durationText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(activity.dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let calories = activity.caloriesBurned {
                    Text("\(calories) cal")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.themePrimaryDarkGreen)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.themeLightAqua.opacity(0.3))
        .cornerRadius(8)
    }
}

extension PhysicalActivity {
    var iconName: String {
        switch self.type {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .yoga: return "figure.yoga"
        case .gym: return "dumbbell"
        case .sports: return "soccerball"
        case .other: return "figure.mixed.cardio"
        }
    }
    
    var durationText: String {
        return "\(duration) min"
    }
    
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}

#Preview {
    PhysicalView()
        .modelContainer(for: [User.self, PhysicalData.self, PhysicalActivity.self], inMemory: true)
}
