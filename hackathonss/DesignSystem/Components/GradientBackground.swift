import SwiftUI

// MARK: - Gradient Background Component
struct GradientBackground: View {
    let gradientType: GradientType
    let animationEnabled: Bool
    let opacity: Double
    
    init(
        gradientType: GradientType = .wellness,
        animationEnabled: Bool = false,
        opacity: Double = 1.0
    ) {
        self.gradientType = gradientType
        self.animationEnabled = animationEnabled
        self.opacity = opacity
    }
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            colors: gradientType.colors,
            startPoint: animationEnabled ? 
            UnitPoint(x: 0.5 + animationOffset, y: 0) : 
            gradientType.startPoint,
            endPoint: animationEnabled ? 
            UnitPoint(x: 0.5 - animationOffset, y: 1) : 
            gradientType.endPoint
        )
        .opacity(opacity)
        .onAppear {
            if animationEnabled {
                withAnimation(
                    Animation.linear(duration: 3.0)
                    .repeatForever(autoreverses: true)
                ) {
                    animationOffset = 0.3
                }
            }
        }
    }
}

// MARK: - Gradient Types
enum GradientType {
    case wellness
    case conversational
    case emotional
    case spiritual
    case physical
    case custom(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint)
    
    var colors: [Color] {
        switch self {
        case .wellness:
            return [Color.themePrimaryDarkGreen, Color.themeTeal, Color.themeLightAqua]
        case .conversational:
            return [Color.themeDeepBlue, Color.themeLavender]
        case .emotional:
            return [Color.themeLavender, Color.themeTeal, Color.themeLightAqua]
        case .spiritual:
            return [Color.themeDeepBlue, Color.themePrimaryDarkGreen]
        case .physical:
            return [Color.themeTeal, Color.themePrimaryDarkGreen]
        case .custom(let colors, _, _):
            return colors
        }
    }
    
    var startPoint: UnitPoint {
        switch self {
        case .wellness:
            return .topLeading
        case .conversational:
            return .topLeading
        case .emotional:
            return .topTrailing
        case .spiritual:
            return .top
        case .physical:
            return .bottomLeading
        case .custom(_, let startPoint, _):
            return startPoint
        }
    }
    
    var endPoint: UnitPoint {
        switch self {
        case .wellness:
            return .bottomTrailing
        case .conversational:
            return .bottomTrailing
        case .emotional:
            return .bottomLeading
        case .spiritual:
            return .bottom
        case .physical:
            return .topTrailing
        case .custom(_, _, let endPoint):
            return endPoint
        }
    }
}

// MARK: - Animated Gradient View
struct AnimatedGradientView: View {
    let gradientType: GradientType
    let content: AnyView
    
    init<Content: View>(
        gradientType: GradientType = .wellness,
        @ViewBuilder content: () -> Content
    ) {
        self.gradientType = gradientType
        self.content = AnyView(content())
    }
    
    var body: some View {
        ZStack {
            GradientBackground(gradientType: gradientType, animationEnabled: true)
                .ignoresSafeArea()
            
            content
        }
    }
}

// MARK: - Wellness Card with Gradient
struct GradientCard<Content: View>: View {
    let gradientType: GradientType
    let title: String?
    let subtitle: String?
    let content: Content
    
    init(
        gradientType: GradientType = .wellness,
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.gradientType = gradientType
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: WellnessSpacing.sm) {
            if let title = title {
                Text(title)
                    .font(.wellnessCardTitle)
                    .foregroundColor(.white)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.wellnessCardSubtitle)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            content
        }
        .padding(WellnessSpacing.cardPadding)
        .background(
            LinearGradient(
                colors: gradientType.colors,
                startPoint: gradientType.startPoint,
                endPoint: gradientType.endPoint
            )
        )
        .cornerRadius(WellnessSpacing.largeRadius)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: WellnessSpacing.mediumRadius,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Wellness Screen Template
struct WellnessScreenTemplate<Content: View>: View {
    let title: String
    let gradientType: GradientType
    let showBackButton: Bool
    let onBackTap: (() -> Void)?
    let content: Content
    
    init(
        title: String,
        gradientType: GradientType = .wellness,
        showBackButton: Bool = false,
        onBackTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.gradientType = gradientType
        self.showBackButton = showBackButton
        self.onBackTap = onBackTap
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            GradientBackground(gradientType: gradientType)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Content
                ScrollView {
                    content
                        .padding(WellnessSpacing.screenPadding)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        HStack {
            if showBackButton {
                Button(action: onBackTap ?? {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(WellnessSpacing.mediumRadius)
                }
            } else {
                Spacer()
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(title)
                .font(.wellnessTitle2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            // Placeholder for symmetry
            Spacer()
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, WellnessSpacing.screenPadding)
        .padding(.top, 50)
        .padding(.bottom, WellnessSpacing.md)
    }
}

// MARK: - Floating Action Button with Gradient
struct GradientFloatingActionButton: View {
    let icon: String
    let gradientType: GradientType
    let action: () -> Void
    let size: CGFloat
    
    init(
        icon: String,
        gradientType: GradientType = .wellness,
        action: @escaping () -> Void,
        size: CGFloat = 56
    ) {
        self.icon = icon
        self.gradientType = gradientType
        self.action = action
        self.size = size
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientType.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.3, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

// MARK: - Progress View with Gradient
struct GradientProgressView: View {
    let progress: Double
    let gradientType: GradientType
    let height: CGFloat
    let showPercentage: Bool
    
    init(
        progress: Double,
        gradientType: GradientType = .wellness,
        height: CGFloat = 8,
        showPercentage: Bool = true
    ) {
        self.progress = progress
        self.gradientType = gradientType
        self.height = height
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        VStack(spacing: WellnessSpacing.sm) {
            if showPercentage {
                HStack {
                    Text("Progreso")
                        .font(.wellnessCaption1)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.wellnessCaption1)
                        .fontWeight(.medium)
                        .foregroundColor(gradientType.colors.first ?? .themeTeal)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: height)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: gradientType.colors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: height)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: height)
        }
    }
}

// MARK: - Previews
#Preview("Gradient Backgrounds") {
    VStack(spacing: WellnessSpacing.md) {
        GradientBackground(gradientType: .wellness)
            .frame(height: 100)
        
        GradientBackground(gradientType: .conversational, animationEnabled: true)
            .frame(height: 100)
        
        GradientBackground(gradientType: .emotional)
            .frame(height: 100)
    }
    .padding()
}

#Preview("Gradient Card") {
    VStack(spacing: WellnessSpacing.md) {
        GradientCard(
            gradientType: .wellness,
            title: "Bienestar Integral",
            subtitle: "Tu progreso general"
        ) {
            HStack {
                Text("75% completado")
                    .font(.wellnessBody)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.white)
            }
        }
        
        GradientCard(
            gradientType: .conversational,
            title: "Análisis Emocional"
        ) {
            Text("Tu estado emocional es estable")
                .font(.wellnessBody)
                .foregroundColor(.white.opacity(0.9))
        }
    }
    .padding()
}

#Preview("Wellness Screen Template") {
    WellnessScreenTemplate(
        title: "Bienestar Emocional",
        gradientType: .conversational,
        showBackButton: true
    ) {
        VStack(spacing: WellnessSpacing.lg) {
            Text("Contenido de la pantalla")
                .font(.wellnessBody)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            GradientFloatingActionButton(
                icon: "plus",
                gradientType: .conversational
            ) {
                print("FAB tapped")
            }
        }
    }
}

#Preview("Gradient Progress") {
    VStack(spacing: WellnessSpacing.lg) {
        GradientProgressView(progress: 0.75, gradientType: .wellness)
        
        GradientProgressView(progress: 0.45, gradientType: .conversational, height: 12)
        
        GradientProgressView(progress: 0.9, gradientType: .emotional, showPercentage: false)
    }
    .padding()
}
