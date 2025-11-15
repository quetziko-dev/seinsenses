import SwiftUI

struct VolunteerSuggestionsView: View {
    @StateObject private var viewModel = VolunteerViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Voluntariado")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Te sugerimos oportunidades de voluntariado para aportar a tu comunidad")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Info Banner
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Compromiso Social")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Actividades inspiradas en apoyo comunitario")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.themePrimaryDarkGreen.opacity(0.1))
                .cornerRadius(12)
                
                // Loading State
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Generando sugerencias personalizadas...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                }
                
                // Suggestions List
                if !viewModel.suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Oportunidades para ti")
                            .font(.headline)
                            .foregroundColor(.themePrimaryDarkGreen)
                        
                        ForEach(viewModel.suggestions) { suggestion in
                            VolunteerCard(suggestion: suggestion)
                        }
                    }
                }
                
                // Error Message
                if let error = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Reintentar") {
                            Task {
                                await viewModel.loadSuggestions()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.themeTeal)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.themeTeal)
                        Text("Importante")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    Text("Estas sugerencias son generales e inspiradas en compromiso social comunitario. Verifica siempre la legitimidad de las organizaciones antes de participar.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.themeTeal.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Voluntariado")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSuggestions()
        }
    }
}

struct VolunteerCard: View {
    let suggestion: VolunteerSuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category tag
            HStack {
                Text(suggestion.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: suggestion.categoryColor))
                    .cornerRadius(8)
                
                Spacer()
            }
            
            // Title
            Text(suggestion.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Description
            Text(suggestion.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Action Button
            Button(action: {
                // TODO: Open more details or contact info
            }) {
                HStack {
                    Text("Más información")
                        .fontWeight(.medium)
                    Image(systemName: "arrow.right")
                }
                .font(.caption)
                .foregroundColor(.themeTeal)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - ViewModel
@MainActor
class VolunteerViewModel: ObservableObject {
    @Published var suggestions: [VolunteerSuggestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: VolunteerAIServiceProtocol = MockVolunteerAIService.shared
    
    func loadSuggestions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Pass user profile if available (can be nil for now)
            suggestions = try await service.suggestVolunteerActivities(for: nil)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "No pudimos generar sugerencias. Intenta más tarde."
        }
    }
}

#Preview {
    NavigationStack {
        VolunteerSuggestionsView()
    }
}
