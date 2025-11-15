import SwiftUI

struct SocialMissionsView: View {
    @State private var currentMission: SocialMission
    @State private var completedCount = UserDefaults.standard.integer(forKey: "completedMissionsCount")
    @State private var showingCompleted = false
    
    private let service = SocialMissionService.shared
    
    init() {
        _currentMission = State(initialValue: SocialMissionService.shared.randomMission())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Misiones Sociales")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Te proponemos pequeñas acciones para fortalecer tus conexiones")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Stats
                HStack(spacing: 20) {
                    StatCard(
                        icon: "checkmark.circle.fill",
                        value: "\(completedCount)",
                        label: "Completadas",
                        color: .themeTeal
                    )
                    
                    StatCard(
                        icon: "target",
                        value: "1",
                        label: "Actual",
                        color: .themeLavender
                    )
                }
                
                // Current Mission Card
                VStack(spacing: 20) {
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.themeTeal)
                    
                    Text("Tu Misión")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text(currentMission.text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(
                    LinearGradient(
                        colors: [Color.themeTeal.opacity(0.1), Color.themeLavender.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.themeTeal.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        markAsCompleted()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Marcar como completada")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeTeal)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        getNewMission()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Otra misión")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.themeTeal)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themeTeal, lineWidth: 1)
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Misiones")
        .navigationBarTitleDisplayMode(.inline)
        .alert("¡Misión Completada! 🎉", isPresented: $showingCompleted) {
            Button("Genial") {
                getNewMission()
            }
        } message: {
            Text("Has fortalecido tus conexiones sociales. ¡Sigue así!")
        }
    }
    
    private func getNewMission() {
        withAnimation {
            currentMission = service.randomMission()
        }
    }
    
    private func markAsCompleted() {
        completedCount += 1
        UserDefaults.standard.set(completedCount, forKey: "completedMissionsCount")
        showingCompleted = true
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        SocialMissionsView()
    }
}
