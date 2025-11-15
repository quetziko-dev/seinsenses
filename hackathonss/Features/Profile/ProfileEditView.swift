import SwiftUI
import SwiftData

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let user: User?
    
    @State private var nickname: String = ""
    @State private var showingSaveAlert = false
    @State private var showPhotoOptions = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCameraPicker = false
    @State private var isShowingDocumentPicker = false
    @State private var selectedUIImage: UIImage?
    @State private var currentAvatarImage: UIImage?
    
    var body: some View {
        Form {
            // Profile Photo Section
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // Avatar Image
                        Button(action: {
                            showPhotoOptions = true
                        }) {
                            ZStack(alignment: .bottomTrailing) {
                                // Avatar Circle
                                if let avatarImage = selectedUIImage ?? currentAvatarImage {
                                    Image(uiImage: avatarImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.themeTeal, lineWidth: 3))
                                } else {
                                    // Placeholder with initials
                                    Circle()
                                        .fill(Color.themeTeal.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Text(getInitials())
                                                .font(.system(size: 40, weight: .medium))
                                                .foregroundColor(.themeTeal)
                                        )
                                        .overlay(Circle().stroke(Color.themeTeal, lineWidth: 3))
                                }
                                
                                // Edit icon
                                Circle()
                                    .fill(Color.themeTeal)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("Toca para cambiar foto")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
            
            Section(header: Text("Información Personal")) {
                HStack {
                    Text("Nombre completo")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(user?.name ?? "")
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Apodo")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    TextField("Cómo quieres que te llame", text: $nickname)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    Text("Este apodo aparecerá en tu pantalla de inicio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Información de la cuenta")) {
                HStack {
                    Text("Fecha de registro")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(user?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Nivel actual")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(user?.pantherProgress.currentLevel.displayName ?? "")
                        .foregroundColor(.themeTeal)
                        .fontWeight(.medium)
                }
            }
        }
        .navigationTitle("Editar Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") {
                    saveNickname()
                }
                .foregroundColor(.themeTeal)
                .fontWeight(.semibold)
            }
        }
        .confirmationDialog("Cambiar foto de perfil", isPresented: $showPhotoOptions, titleVisibility: .visible) {
            Button("Fototeca") {
                isShowingPhotoPicker = true
            }
            Button("Tomar foto") {
                isShowingCameraPicker = true
            }
            Button("Seleccionar archivo") {
                isShowingDocumentPicker = true
            }
            Button("Cancelar", role: .cancel) {}
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoLibraryPicker(image: $selectedUIImage)
        }
        .sheet(isPresented: $isShowingCameraPicker) {
            CameraPicker(image: $selectedUIImage)
        }
        .sheet(isPresented: $isShowingDocumentPicker) {
            DocumentImagePicker(image: $selectedUIImage)
        }
        .onChange(of: selectedUIImage) { _, newImage in
            if let image = newImage, let user = user {
                if user.saveAvatarImage(image) {
                    currentAvatarImage = image
                    try? modelContext.save()
                    print("✅ Avatar guardado exitosamente")
                }
            }
        }
        .onAppear {
            nickname = user?.nickname ?? ""
            currentAvatarImage = user?.loadAvatarImage()
        }
        .alert("Perfil actualizado", isPresented: $showingSaveAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Tu perfil ha sido actualizado correctamente")
        }
    }
    
    private func getInitials() -> String {
        guard let user = user else { return "?" }
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
    
    private func saveNickname() {
        guard let user = user else { return }
        
        // Update nickname
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        user.nickname = trimmedNickname.isEmpty ? nil : trimmedNickname
        
        // Save context
        do {
            try modelContext.save()
            showingSaveAlert = true
        } catch {
            print("Error saving nickname: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(user: nil)
    }
    .modelContainer(for: [User.self], inMemory: true)
}
