import SwiftUI

struct SignInView: View {
    @Binding var isSignUp: Bool
    @Binding var showingForgotPassword: Bool
    
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
                                    .frame(width: 140, height: 140)
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
                        Text("Log in on")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.themePrimaryDarkGreen.opacity(0.7))
                        
                        Text("SEISENSE")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.themePrimaryDarkGreen)
                            .tracking(1.5)
                    }
                    .padding(.bottom, 20)
                }
                .frame(height: 280)
                
                // Form section with soft white containers
                VStack(spacing: 20) {
                    // Email field in white container
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
                    
                    // Password field in white container
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
                    
                    // Main login button
                    Button(action: signIn) {
                        HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("LOGIN WITH EMAIL")
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
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    .padding(.horizontal, 30)
                    
                    // Bottom links with gentle styling
                    VStack(spacing: 12) {
                        Button(action: { showingForgotPassword = true }) {
                            Text("Forgot Password? Click Here")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.themePrimaryDarkGreen.opacity(0.7))
                        }
                        
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.subheadline)
                                .foregroundColor(.themePrimaryDarkGreen.opacity(0.6))
                            
                            Button(action: { isSignUp = true }) {
                                Text("Sign up")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.themeTeal)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .padding(.top, 30)
            }
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor completa todos los campos"
            showError = true
            return
        }
        
        isLoading = true
        
        Task {
            let success = await AuthenticationManager.shared.signIn(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
                if !success {
                    errorMessage = "Credenciales inválidas"
                    showError = true
                }
            }
        }
    }
}

// Custom Blob Shape
struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.2, y: 0))
        path.addCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.15),
            control1: CGPoint(x: width * 0.5, y: -height * 0.1),
            control2: CGPoint(x: width * 0.7, y: height * 0.05)
        )
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.6),
            control1: CGPoint(x: width * 0.95, y: height * 0.3),
            control2: CGPoint(x: width * 1.05, y: height * 0.45)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.6, y: height),
            control1: CGPoint(x: width * 0.95, y: height * 0.8),
            control2: CGPoint(x: width * 0.8, y: height * 0.95)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.7),
            control1: CGPoint(x: width * 0.3, y: height * 1.05),
            control2: CGPoint(x: width * 0.1, y: height * 0.85)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.2, y: 0),
            control1: CGPoint(x: -width * 0.1, y: height * 0.5),
            control2: CGPoint(x: width * 0.05, y: height * 0.15)
        )
        
        return path
    }
}

#Preview {
    SignInView(
        isSignUp: .constant(false),
        showingForgotPassword: .constant(false)
    )
}
