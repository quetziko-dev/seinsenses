import SwiftUI

struct LanguageSelectionView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "es"
    
    let languages = [
        Language(code: "es", name: "Español", nativeName: "Español", flag: "🇪🇸"),
        Language(code: "en", name: "English", nativeName: "English", flag: "🇺🇸")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Idioma de la aplicación")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Selecciona tu idioma preferido")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Language List
                VStack(spacing: 0) {
                    ForEach(Array(languages.enumerated()), id: \.element.code) { index, language in
                        Button(action: {
                            selectedLanguage = language.code
                        }) {
                            HStack(spacing: 16) {
                                Text(language.flag)
                                    .font(.system(size: 32))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(language.nativeName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text(language.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedLanguage == language.code {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.themeTeal)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(selectedLanguage == language.code ? Color.themeTeal.opacity(0.1) : Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if index < languages.count - 1 {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Info Banner
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.themeTeal)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Funcionalidad en desarrollo")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("La traducción completa estará disponible próximamente")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.themeTeal.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Idioma")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Language: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let nativeName: String
    let flag: String
}

#Preview {
    NavigationStack {
        LanguageSelectionView()
    }
}
