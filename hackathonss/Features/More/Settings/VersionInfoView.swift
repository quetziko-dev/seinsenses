import SwiftUI

struct VersionInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // App Icon/Logo
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.themeTeal)
                
                // App Name
                Text("Seinsense")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.themePrimaryDarkGreen)
                
                // Tagline
                Text("Tu compañero de bienestar integral")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Version Info
                VStack(spacing: 8) {
                    HStack {
                        Text("Versión")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(appVersion)
                            .fontWeight(.medium)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Build")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(buildNumber)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .padding(.horizontal)
                
                // Footer
                VStack(spacing: 4) {
                    Text("© 2025 Seinsense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Hecho con ❤️ para tu bienestar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Close Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cerrar")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeTeal)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.themeLightAqua)
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    VersionInfoView()
}
