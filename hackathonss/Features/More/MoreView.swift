import SwiftUI
import SwiftData

struct MoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var showLogoutAlert = false
    @State private var showVersionSheet = false
    
    private var currentUser: User? {
        users.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Section
                    profileSection
                    
                    // Additional Wellness Areas
                    additionalAreasSection
                    
                    // Settings
                    settingsSection
                    
                    // About
                    aboutSection
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Más")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tu Perfil")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            NavigationLink(destination: ProfileEditView(user: currentUser)) {
                HStack {
                    // Avatar image or placeholder
                    if let user = currentUser, let avatarImage = user.loadAvatarImage() {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.themeTeal, lineWidth: 2))
                    } else {
                        // Placeholder with initials
                        Circle()
                            .fill(Color.themeTeal.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(getInitials())
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.themeTeal)
                            )
                            .overlay(Circle().stroke(Color.themeTeal, lineWidth: 2))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Usar displayName: nickname si existe, sino nombre completo, sino "Usuario"
                        Text(currentUser?.displayName ?? "Usuario")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if let user = currentUser {
                            Text("Miembro desde: \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Miembro desde: Hoy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func getInitials() -> String {
        guard let user = currentUser else { return "?" }
        let displayName = user.displayName
        let components = displayName.split(separator: " ")
        
        if components.count >= 2 {
            let first = String(components[0].prefix(1))
            let last = String(components[1].prefix(1))
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        
        return "?"
    }
    
    private var additionalAreasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Áreas de Bienestar")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 12) {
                WellnessAreaRow(
                    title: "Ocupacional",
                    description: "Equilibrio trabajo-vida y desarrollo profesional",
                    icon: "briefcase.fill",
                    color: .themeTeal
                )
                
                WellnessAreaRow(
                    title: "Ambiental",
                    description: "Conexión con tu entorno y espacios saludables",
                    icon: "leaf.fill",
                    color: .themePrimaryDarkGreen
                )
                
                NavigationLink(destination: SpiritualView()) {
                    WellnessAreaRow(
                        title: "Espiritual",
                        description: "Conexión interior y sentido de propósito",
                        icon: "moon.fill",
                        color: .themeLavender
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configuración")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 12) {
                NavigationLink(destination: NotificationsSettingsView()) {
                    SettingsRow(
                        title: "Notificaciones",
                        description: "Gestiona tus recordatorios",
                        icon: "bell.fill",
                        color: .themeLavender
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: PrivacySettingsView()) {
                    SettingsRow(
                        title: "Privacidad",
                        description: "Protección de tus datos",
                        icon: "lock.fill",
                        color: .themeDeepBlue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: LanguageSelectionView()) {
                    SettingsRow(
                        title: "Idioma",
                        description: "Español",
                        icon: "globe",
                        color: .themeTeal
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.vertical, 8)
                
                Button(action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.themeError)
                            .frame(width: 24)
                        
                        Text("Cerrar sesión")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.themeError)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("Cerrar sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar sesión", role: .destructive) {
                Task { @MainActor in
                    // Usar SessionManager para logout limpio (borra todos los datos)
                    SessionManager.shared.performCleanLogout()
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres cerrar sesión?\n\nTodos tus datos locales serán eliminados.")
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acerca de")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 12) {
                Button(action: {
                    showVersionSheet = true
                }) {
                    AboutRow(
                        title: "Versión",
                        description: "1.0.0",
                        icon: "info.circle",
                        color: .themeTeal
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: SupportCenterView()) {
                    AboutRow(
                        title: "Ayuda",
                        description: "Centro de ayuda y soporte",
                        icon: "questionmark.circle",
                        color: .themeLavender
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showVersionSheet) {
            VersionInfoView()
        }
    }
}

struct WellnessAreaRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
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

struct SettingsRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
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

struct AboutRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if title == "Versión" {
                Spacer()
            } else {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MoreView()
}
