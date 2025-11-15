import SwiftUI

struct SocialView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    welcomeSection
                    
                    // Social Activities
                    socialActivitiesSection
                    
                    // Connections
                    connectionsSection
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Bienestar Social")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Conexiones Sociales")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("Cultiva relaciones saludables y tu red de apoyo")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var socialActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividades Sociales")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: SocialMissionsView()) {
                    SocialActivityCardView(
                        title: "Misiones",
                        icon: "target",
                        color: .themeTeal
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: SocialPlansCalendarView()) {
                    SocialActivityCardView(
                        title: "Encuentro amigos",
                        icon: "person.2.fill",
                        color: .themeLavender
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: CommunityGroupsView()) {
                    SocialActivityCardView(
                        title: "Grupo comunitario",
                        icon: "person.3.fill",
                        color: .themeDeepBlue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: VolunteerSuggestionsView()) {
                    SocialActivityCardView(
                        title: "Voluntariado",
                        icon: "heart.fill",
                        color: .themePrimaryDarkGreen
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var connectionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tu Red de Apoyo")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 12) {
                ConnectionRow(
                    name: "Familia",
                    description: "Miembros cercanos",
                    icon: "house.fill",
                    color: .themeTeal
                )
                
                ConnectionRow(
                    name: "Amigos",
                    description: "Amistades importantes",
                    icon: "person.2.fill",
                    color: .themeLavender
                )
                
                ConnectionRow(
                    name: "Comunidad",
                    description: "Grupos de interés",
                    icon: "person.3.fill",
                    color: .themeDeepBlue
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SocialActivityCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
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
}

struct SocialActivityCardView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
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
}

struct ConnectionRow: View {
    let name: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SocialView()
}
