import SwiftUI
import UserNotifications

struct NotificationsSettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("waterReminder") private var waterReminder = false
    @AppStorage("movementReminder") private var movementReminder = false
    @AppStorage("breathingReminder") private var breathingReminder = false
    
    @State private var showingPermissionAlert = false
    @State private var permissionDenied = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gestiona tus recordatorios")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Configura las notificaciones para recordarte tus hábitos de bienestar")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Main Toggle
                VStack(spacing: 0) {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.themeLavender)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Notificaciones")
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Text(notificationsEnabled ? "Activadas" : "Desactivadas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(.themeTeal)
                    .onChange(of: notificationsEnabled) { oldValue, newValue in
                        if newValue {
                            requestNotificationPermissions()
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Reminders Section
                if notificationsEnabled {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recordatorios")
                            .font(.headline)
                            .foregroundColor(.themePrimaryDarkGreen)
                        
                        VStack(spacing: 12) {
                            ReminderToggle(
                                isOn: $waterReminder,
                                icon: "drop.fill",
                                title: "Recordarme beber agua",
                                description: "Cada 2 horas durante el día",
                                color: .themeTeal
                            )
                            
                            Divider()
                            
                            ReminderToggle(
                                isOn: $movementReminder,
                                icon: "figure.walk",
                                title: "Recordarme moverme",
                                description: "Cada hora durante el día",
                                color: .themePrimaryDarkGreen
                            )
                            
                            Divider()
                            
                            ReminderToggle(
                                isOn: $breathingReminder,
                                icon: "lungs.fill",
                                title: "Recordarme respirar",
                                description: "1 minuto de respiración consciente",
                                color: .themeLavender
                            )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Permisos de Notificaciones", isPresented: $showingPermissionAlert) {
            Button("OK") { }
        } message: {
            if permissionDenied {
                Text("Para habilitar notificaciones, ve a Configuración > seinsense > Notificaciones")
            } else {
                Text("Notificaciones habilitadas correctamente")
            }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Permisos de notificaciones otorgados")
                    showingPermissionAlert = true
                    permissionDenied = false
                } else {
                    print("❌ Permisos de notificaciones denegados")
                    notificationsEnabled = false
                    showingPermissionAlert = true
                    permissionDenied = true
                }
            }
        }
    }
}

struct ReminderToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .tint(.themeTeal)
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
}
