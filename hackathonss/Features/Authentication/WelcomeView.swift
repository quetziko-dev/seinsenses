import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var animateGradient = false
    @State private var bubbleScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Soft gradient background
            Color.themeLightAqua
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Friendly panther mascot with speech bubble (centered)
                ZStack(alignment: .topTrailing) {
                    // Main panther image from custom path - centered
                    HStack {
                        Spacer()
                        VStack {
                            let imagePath = "/Users/iOS Lab UPMX/Documents/0284001/pantera.png"
                            
                            if let uiImage = UIImage(contentsOfFile: imagePath) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 180, height: 180)
                            } else {
                                // Fallback a SF Symbol si no encuentra la imagen
                                Image(systemName: "pawprint.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.themePrimaryDarkGreen)
                            }
                        }
                        Spacer()
                    }
                    
                    // "Hi!" speech bubble
                    ZStack {
                        // Bubble tail
                        Path { path in
                            path.move(to: CGPoint(x: 10, y: 40))
                            path.addLine(to: CGPoint(x: 0, y: 50))
                            path.addLine(to: CGPoint(x: 15, y: 45))
                        }
                        .fill(Color.white)
                        .offset(x: -15, y: 25)
                        
                        // Main bubble
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(width: 70, height: 50)
                            .shadow(color: .themeTeal.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Text("Hi!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.themeTeal)
                    }
                    .scaleEffect(bubbleScale)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            bubbleScale = 1.0
                        }
                    }
                }
                
                VStack(spacing: 16) {
                    // Welcome text with gentle animation
                    Text("bienvenido a")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.themePrimaryDarkGreen.opacity(0.7))
                    
                    Text("SEISENSE")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.themePrimaryDarkGreen)
                        .tracking(1.5)
                    
                    Text("Tu compañero de bienestar integral")
                        .font(.body)
                        .foregroundColor(.themePrimaryDarkGreen.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 4)
                }
                
                Spacer()
                
                // Gentle start button
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showWelcome = false
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Comenzar")
                            .fontWeight(.semibold)
                            .font(.title3)
                        
                        Image(systemName: "arrow.right")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.themePrimaryDarkGreen)
                    .cornerRadius(25)
                    .shadow(color: .themePrimaryDarkGreen.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    WelcomeView(showWelcome: .constant(true))
}
