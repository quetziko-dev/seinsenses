import SwiftUI

struct CommunityGroupsView: View {
    @StateObject private var viewModel = CommunityGroupsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Grupos Comunitarios")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Únete a grupos temporales de 72 horas basados en intereses comunes")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Info Card
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.themeTeal)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Grupos efímeros")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Cada grupo dura 72 horas desde su creación")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.themeTeal.opacity(0.1))
                .cornerRadius(12)
                
                // Loading State
                if viewModel.isLoading {
                    ProgressView("Cargando grupos...")
                        .padding(40)
                }
                
                // Groups List
                if !viewModel.groups.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Grupos Disponibles")
                            .font(.headline)
                            .foregroundColor(.themePrimaryDarkGreen)
                        
                        ForEach(viewModel.groups) { group in
                            GroupCard(group: group, onJoin: {
                                viewModel.joinGroup(group)
                            })
                        }
                    }
                }
                
                // Empty State
                if !viewModel.isLoading && viewModel.groups.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 60))
                            .foregroundColor(.themeTeal.opacity(0.5))
                        
                        Text("No hay grupos activos")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Intenta recargar más tarde")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                }
                
                // Error Message
                if let error = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Comunidad")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadGroups()
        }
        .navigationDestination(isPresented: $viewModel.showingChat) {
            if let selectedGroup = viewModel.selectedGroup {
                CommunityChatView(group: selectedGroup)
            }
        }
    }
}

struct GroupCard: View {
    let group: CommunityGroup
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(group.timeRemaining)
                        .font(.caption)
                }
                .foregroundColor(group.isExpired ? .red : .themeTeal)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(group.isExpired ? Color.red.opacity(0.1) : Color.themeTeal.opacity(0.1))
                .cornerRadius(8)
            }
            
            Text(group.topic)
                .font(.body)
                .foregroundColor(.secondary)
            
            if !group.isExpired {
                Button(action: onJoin) {
                    HStack {
                        Image(systemName: group.isJoined ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                        Text(group.isJoined ? "Unido" : "Unirme")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(group.isJoined ? Color.gray.opacity(0.2) : Color.themeTeal)
                    .foregroundColor(group.isJoined ? .primary : .white)
                    .cornerRadius(10)
                }
                .disabled(group.isJoined)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text("Grupo expirado")
                }
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
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
class CommunityGroupsViewModel: ObservableObject {
    @Published var groups: [CommunityGroup] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingChat = false
    @Published var selectedGroup: CommunityGroup?
    
    private let service: CommunityGroupServiceProtocol = MockCommunityGroupService.shared
    
    func loadGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            groups = try await service.fetchAvailableGroups()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "No pudimos cargar los grupos. Intenta más tarde."
        }
    }
    
    func joinGroup(_ group: CommunityGroup) {
        Task {
            do {
                let joinedGroup = try await service.joinGroup(group)
                
                // Update local group
                if let index = groups.firstIndex(where: { $0.id == group.id }) {
                    groups[index] = joinedGroup
                }
                
                // Navigate to chat
                selectedGroup = joinedGroup
                showingChat = true
            } catch {
                errorMessage = "No pudimos unirte al grupo. Intenta de nuevo."
            }
        }
    }
}

// MARK: - Chat View (Stub)
struct CommunityChatView: View {
    let group: CommunityGroup
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.themeTeal.opacity(0.5))
                
                Text("Chat Comunitario")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.themeTeal)
                
                Text("El chat de grupo estará disponible próximamente")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Funcionalidades futuras:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("• Mensajería en tiempo real")
                        .font(.caption)
                    Text("• Notificaciones push")
                        .font(.caption)
                    Text("• Compartir multimedia")
                        .font(.caption)
                    Text("• Moderación de contenido")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                .padding()
                .background(Color.themeLightAqua.opacity(0.3))
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.themeLightAqua)
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CommunityGroupsView()
    }
}
