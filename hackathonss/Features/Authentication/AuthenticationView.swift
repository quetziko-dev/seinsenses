import SwiftUI

struct AuthenticationView: View {
    @State private var showWelcome = true
    @State private var isSignUp = false
    @State private var showingForgotPassword = false
    
    var body: some View {
        ZStack {
            if showWelcome {
                WelcomeView(showWelcome: $showWelcome)
                    .transition(.opacity)
            } else {
                if isSignUp {
                    SignUpView(isSignUp: $isSignUp)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    SignInView(isSignUp: $isSignUp, showingForgotPassword: $showingForgotPassword)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        ))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSignUp)
        .animation(.easeInOut(duration: 0.5), value: showWelcome)
    }
}

#Preview {
    AuthenticationView()
}
