import SwiftUI

// MARK: - Panther Avatar Component
struct PantherAvatar: View {
    let level: PantherLevel
    let size: AvatarSize
    let isAnimated: Bool
    let customOutfit: PantherOutfit?
    
    init(
        level: PantherLevel = .cub,
        size: AvatarSize = .medium,
        isAnimated: Bool = false,
        customOutfit: PantherOutfit? = nil
    ) {
        self.level = level
        self.size = size
        self.isAnimated = isAnimated
        self.customOutfit = customOutfit
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(backgroundColorForLevel)
                .frame(width: size.frameSize, height: size.frameSize)
                .overlay(
                    Circle()
                        .stroke(backgroundColorForLevel.opacity(0.3), lineWidth: 2)
                )
            
            // Panther body
            pantherBody
            
            // Panther features
            pantherFeatures
            
            // Outfit if available
            if let outfit = customOutfit {
                pantherOutfit(outfit)
            }
            
            // Level indicator
            levelIndicator
        }
        .scaleEffect(isAnimated ? 1.05 : 1.0)
        .animation(
            isAnimated ? 
            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true) : 
            .default,
            value: isAnimated
        )
    }
    
    private var pantherBody: some View {
        ZStack {
            // Main body shape
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(bodyColorForLevel)
                .frame(
                    width: size.frameSize * 0.7,
                    height: size.frameSize * 0.6
                )
            
            // Head
            Circle()
                .fill(bodyColorForLevel)
                .frame(
                    width: size.frameSize * 0.4,
                    height: size.frameSize * 0.4
                )
                .offset(y: -size.frameSize * 0.15)
        }
    }
    
    private var pantherFeatures: some View {
        VStack(spacing: 0) {
            // Eyes
            HStack(spacing: size.frameSize * 0.08) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size.frameSize * 0.08, height: size.frameSize * 0.08)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: size.frameSize * 0.08, height: size.frameSize * 0.08)
            }
            .offset(y: -size.frameSize * 0.18)
            
            // Pupils
            HStack(spacing: size.frameSize * 0.08) {
                Circle()
                    .fill(Color.black)
                    .frame(width: size.frameSize * 0.04, height: size.frameSize * 0.04)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: size.frameSize * 0.04, height: size.frameSize * 0.04)
            }
            .offset(y: -size.frameSize * 0.18)
            
            // Nose
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.6))
                .frame(width: size.frameSize * 0.03, height: size.frameSize * 0.02)
                .offset(y: -size.frameSize * 0.08)
            
            // Mouth/Smile
            Path { path in
                path.move(to: CGPoint(x: -size.frameSize * 0.06, y: -size.frameSize * 0.04))
                path.addQuadCurve(
                    to: CGPoint(x: size.frameSize * 0.06, y: -size.frameSize * 0.04),
                    control: CGPoint(x: 0, y: size.frameSize * 0.02)
                )
            }
            .stroke(Color.black.opacity(0.4), lineWidth: 1.5)
            .offset(y: -size.frameSize * 0.04)
            
            // Ears
            HStack(spacing: size.frameSize * 0.2) {
                Triangle()
                    .fill(bodyColorForLevel)
                    .frame(width: size.frameSize * 0.12, height: size.frameSize * 0.15)
                    .rotationEffect(.degrees(-15))
                
                Triangle()
                    .fill(bodyColorForLevel)
                    .frame(width: size.frameSize * 0.12, height: size.frameSize * 0.15)
                    .rotationEffect(.degrees(15))
            }
            .offset(y: -size.frameSize * 0.32)
        }
    }
    
    private func pantherOutfit(_ outfit: PantherOutfit) -> some View {
        ZStack {
            if outfit.type == .jacket {
                // Jacket
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(outfit.color)
                    .frame(
                        width: size.frameSize * 0.6,
                        height: size.frameSize * 0.4
                    )
                    .offset(y: size.frameSize * 0.05)
            }
            
            if outfit.type == .sports {
                // Sports outfit
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(outfit.color)
                    .frame(
                        width: size.frameSize * 0.65,
                        height: size.frameSize * 0.35
                    )
                    .offset(y: size.frameSize * 0.08)
            }
        }
    }
    
    private var levelIndicator: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Circle()
                    .fill(Color.white)
                    .frame(width: size.frameSize * 0.2, height: size.frameSize * 0.2)
                    .overlay(
                        Text(levelIcon)
                            .font(.system(size: size.frameSize * 0.1, weight: .bold))
                            .foregroundColor(levelIconColor)
                    )
            }
        }
        .frame(width: size.frameSize, height: size.frameSize)
    }
    
    private var backgroundColorForLevel: Color {
        switch level {
        case .cub: return Color.themeLightAqua.opacity(0.3)
        case .young: return Color.themeTeal.opacity(0.3)
        case .adult: return Color.themePrimaryDarkGreen.opacity(0.3)
        }
    }
    
    private var bodyColorForLevel: Color {
        switch level {
        case .cub: return Color.black.opacity(0.8)
        case .young: return Color.black.opacity(0.85)
        case .adult: return Color.black.opacity(0.9)
        }
    }
    
    private var levelIcon: String {
        switch level {
        case .cub: return "1"
        case .young: return "2"
        case .adult: return "3"
        }
    }
    
    private var levelIconColor: Color {
        switch level {
        case .cub: return Color.themeTeal
        case .young: return Color.themeLavender
        case .adult: return Color.themePrimaryDarkGreen
        }
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// MARK: - Avatar Size
enum AvatarSize {
    case small
    case medium
    case large
    case extraLarge
    
    var frameSize: CGFloat {
        switch self {
        case .small: return 40
        case .medium: return 60
        case .large: return 80
        case .extraLarge: return 120
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 18
        case .large: return 24
        case .extraLarge: return 36
        }
    }
}

// MARK: - Panther Outfit
struct PantherOutfit {
    let type: OutfitType
    let color: Color
    let name: String
    
    init(type: OutfitType, color: Color, name: String) {
        self.type = type
        self.color = color
        self.name = name
    }
    
    static let defaultOutfits: [PantherOutfit] = [
        PantherOutfit(type: .jacket, color: .themeTeal, name: "Chaqueta Deportiva"),
        PantherOutfit(type: .jacket, color: .themeLavender, name: "Chaqueta Casual"),
        PantherOutfit(type: .sports, color: .themePrimaryDarkGreen, name: "Equipamiento Deportivo"),
        PantherOutfit(type: .sports, color: .themeDeepBlue, name: "Ropa de Yoga")
    ]
}

enum OutfitType {
    case jacket
    case sports
    case formal
    case casual
}

// MARK: - Interactive Panther Avatar
struct InteractivePantherAvatar: View {
    @State private var isAnimating = false
    @State private var currentOutfitIndex = 0
    let level: PantherLevel
    let size: AvatarSize
    let availableOutfits: [PantherOutfit]
    
    init(
        level: PantherLevel = .cub,
        size: AvatarSize = .medium,
        availableOutfits: [PantherOutfit] = PantherOutfit.defaultOutfits
    ) {
        self.level = level
        self.size = size
        self.availableOutfits = availableOutfits
    }
    
    var body: some View {
        VStack(spacing: WellnessSpacing.md) {
            PantherAvatar(
                level: level,
                size: size,
                isAnimated: isAnimating,
                customOutfit: availableOutfits.isEmpty ? nil : availableOutfits[currentOutfitIndex]
            )
            
            if !availableOutfits.isEmpty {
                HStack(spacing: WellnessSpacing.sm) {
                    Button("Animar") {
                        isAnimating.toggle()
                    }
                    .buttonStyle(TextButtonStyle())
                    
                    Button("Cambiar") {
                        currentOutfitIndex = (currentOutfitIndex + 1) % availableOutfits.count
                    }
                    .buttonStyle(TextButtonStyle())
                }
            }
        }
    }
}

// MARK: - Panther Progress Card
struct PantherProgressCard: View {
    let progress: PantherProgress
    let onAvatarTap: () -> Void
    
    var body: some View {
        WellnessCard(
            title: "Tu Pantera",
            subtitle: progress.currentLevel.description,
            icon: "pawprint.fill",
            iconColor: .themeTeal
        ) {
            HStack {
                InteractivePantherAvatar(
                    level: progress.currentLevel,
                    size: .large,
                    availableOutfits: progress.unlockedFeatures.contains("custom_panther_outfits") ? 
                        PantherOutfit.defaultOutfits : []
                )
                .onTapGesture {
                    onAvatarTap()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: WellnessSpacing.sm) {
                    // Experience bar
                    VStack(alignment: .trailing, spacing: WellnessSpacing.xs) {
                        Text("Experiencia")
                            .font(.wellnessCaption1)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: progress.progressPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: .themeTeal))
                            .frame(width: 80)
                        
                        Text("\(Int(progress.progressPercentage * 100))%")
                            .font(.wellnessCaption1)
                            .fontWeight(.medium)
                            .foregroundColor(.themePrimaryDarkGreen)
                    }
                    
                    // Stats
                    VStack(alignment: .trailing, spacing: WellnessSpacing.xs) {
                        StatItem(label: "Nivel", value: "\(progress.currentLevel == .cub ? 1 : progress.currentLevel == .young ? 2 : 3)")
                        StatItem(label: "Días", value: "\(progress.consecutiveDays)")
                        StatItem(label: "Actividades", value: "\(progress.totalWellnessActivities)")
                    }
                }
            }
        }
    }
}

private struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.wellnessCaption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.wellnessCaption2)
                .fontWeight(.medium)
                .foregroundColor(.themePrimaryDarkGreen)
        }
    }
}

// MARK: - Previews
#Preview("Panther Avatar") {
    VStack(spacing: WellnessSpacing.lg) {
        HStack(spacing: WellnessSpacing.md) {
            PantherAvatar(level: .cub, size: .small)
            PantherAvatar(level: .young, size: .medium, isAnimated: true)
            PantherAvatar(level: .adult, size: .large, customOutfit: .defaultOutfits[0])
        }
        
        InteractivePantherAvatar(level: .young, size: .extraLarge)
    }
    .padding()
}

#Preview("Panther Progress Card") {
    let progress = PantherProgress()
    progress.addExperience(points: 50)
    progress.updateDailyActivity()
    
    return PantherProgressCard(progress: progress) {
        print("Avatar tapped!")
    }
    .padding()
}
