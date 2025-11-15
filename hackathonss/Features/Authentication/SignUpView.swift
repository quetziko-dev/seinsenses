import SwiftUI

struct SignUpView: View {
    @Binding var isSignUp: Bool
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animateGradient = false
    @State private var animateBlobs = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Soft background
            Color.themeLightAqua
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section with friendly panther (centered)
                VStack(spacing: 20) {
                    // Custom panther image from custom path - centered
                    HStack {
                        Spacer()
                        VStack {
                            let imagePath = "/Users/iOS Lab UPMX/Documents/0284001/pantera.png"
                            
                            if let uiImage = UIImage(contentsOfFile: imagePath) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 130, height: 130)
                            } else {
                                // Fallback
                                Image(systemName: "pawprint.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.themePrimaryDarkGreen)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 60)
                    
                    // Gentle title
                    VStack(spacing: 8) {
                        Text("Join")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.themePrimaryDarkGreen.opacity(0.7))
                        
                        Text("SEISENSE")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.themePrimaryDarkGreen)
                            .tracking(1.5)
                    }
                    .padding(.bottom, 10)
                }
                .frame(height: 260)
                
                // Form section with soft containers
                VStack(spacing: 16) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.themePrimaryDarkGreen.opacity(0.7))
                            .padding(.leading, 6)
                        
                        TextField("Your full name", text: $name)
                            .autocorrectionDisabled(true)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .themeTeal.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.themePrimaryDarkGreen.opacity(0.7))
                            .padding(.leading, 6)
                        
                        TextField("your@email.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .themeTeal.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.themePrimaryDarkGreen.opacity(0.7))
                            .padding(.leading, 6)
                        
                        SecureField("••••••••", text: $password)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .themeTeal.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Main sign up button
                    Button(action: signUp) {
                        HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("CREATE ACCOUNT")
                                    .fontWeight(.semibold)
                                    .font(.headline)
                                
                                Image(systemName: "arrow.right")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.themePrimaryDarkGreen)
                        .cornerRadius(25)
                        .shadow(color: .themePrimaryDarkGreen.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty)
                    .opacity((name.isEmpty || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    .padding(.horizontal, 30)
                    
                    // Bottom link
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .foregroundColor(.themePrimaryDarkGreen.opacity(0.6))
                        
                        Button(action: { isSignUp = false }) {
                            Text("Log in")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.themeTeal)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func signUp() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor completa todos los campos"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
            showError = true
            return
        }
        
        isLoading = true
        
        Task {
            let success = await AuthenticationManager.shared.signUp(name: name, email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                if !success {
                    errorMessage = "Error al crear la cuenta. Intenta de nuevo."
                    showError = true
                }
            }
        }
    }
}

#Preview {
    SignUpView(isSignUp: .constant(true))
}
