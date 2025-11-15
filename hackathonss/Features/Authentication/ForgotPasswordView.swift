import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.themeTeal)
                    
                    Text("¿Olvidaste tu contraseña?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Email field
                CustomTextField(
                    placeholder: "Correo electrónico",
                    text: $email,
                    keyboardType: .emailAddress
                )
                .padding(.horizontal)
                
                // Send button
                Button(action: sendResetEmail) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Enviar instrucciones")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.themeTeal)
                    .foregroundColor(.white)
                    .cornerRadius(WellnessSpacing.buttonRadius)
                }
                .disabled(isLoading || email.isEmpty)
                .opacity(email.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Cerrar") {
                dismiss()
            })
            .alert("¡Correo enviado!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Hemos enviado las instrucciones para restablecer tu contraseña a \(email)")
            }
        }
    }
    
    private func sendResetEmail() {
        isLoading = true
        
        Task {
            let success = await AuthenticationManager.shared.resetPassword(email: email)
            
            await MainActor.run {
                isLoading = false
                if success {
                    showSuccess = true
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
