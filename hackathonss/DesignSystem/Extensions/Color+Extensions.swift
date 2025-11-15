import SwiftUI

// MARK: - Color Extensions for Wellness App
extension Color {
    
    // MARK: - Hex Color Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Wellness Theme Colors
    static let wellnessPrimary = Color.themePrimaryDarkGreen
    static let wellnessSecondary = Color.themeTeal
    static let wellnessAccent = Color.themeLavender
    static let wellnessBackground = Color.themeLightAqua
    static let wellnessSurface = Color.white
    static let wellnessError = Color.themeError
    static let wellnessWarning = Color.themeWarning
    static let wellnessSuccess = Color.themeSuccess
    static let wellnessInfo = Color.themeInfo
    
    // MARK: - Emotion Colors
    static let emotionHappy = Color(hex: "#FFD700")
    static let emotionSad = Color(hex: "#4682B4")
    static let emotionAnxious = Color(hex: "#FF69B4")
    static let emotionAngry = Color(hex: "#DC143C")
    static let emotionGrateful = Color(hex: "#98FB98")
    static let emotionPeaceful = Color(hex: "#87CEEB")
    static let emotionStressed = Color(hex: "#FF8C00")
    static let emotionExcited = Color(hex: "#FF1493")
    static let emotionTired = Color(hex: "#708090")
    static let emotionConfused = Color(hex: "#9370DB")
    
    // MARK: - Level Colors
    static let levelCub = Color.themeTeal
    static let levelYoung = Color.themeLavender
    static let levelAdult = Color.themePrimaryDarkGreen
    
    // MARK: - Utility Methods
    func lighter(by amount: CGFloat = 0.2) -> Color {
        self.opacity(1.0 - amount)
    }
    
    func darker(by amount: CGFloat = 0.2) -> Color {
        self.opacity(max(0.0, 1.0 + amount))
    }
    
    func withAlpha(_ alpha: Double) -> Color {
        self.opacity(alpha)
    }
    
    // MARK: - Color Combinations
    static func wellnessGradient(for type: GradientType) -> LinearGradient {
        LinearGradient(
            colors: type.colors,
            startPoint: type.startPoint,
            endPoint: type.endPoint
        )
    }
    
    static func emotionColor(for emotion: EmotionType) -> Color {
        switch emotion {
        case .happy: return .emotionHappy
        case .sad: return .emotionSad
        case .anxious: return .emotionAnxious
        case .angry: return .emotionAngry
        case .grateful: return .emotionGrateful
        case .peaceful: return .emotionPeaceful
        case .stressed: return .emotionStressed
        case .excited: return .emotionExcited
        case .tired: return .emotionTired
        case .confused: return .emotionConfused
        }
    }
    
    static func levelColor(for level: PantherLevel) -> Color {
        switch level {
        case .cub: return .levelCub
        case .young: return .levelYoung
        case .adult: return .levelAdult
        }
    }
    
    static func severityColor(for severity: AIEmotionAnalysisResult.SeverityLevel) -> Color {
        switch severity {
        case .low: return .wellnessSuccess
        case .medium: return .wellnessWarning
        case .high: return .themeWarning
        case .critical: return .wellnessError
        }
    }
}

// MARK: - Color Scheme Extensions
extension ColorScheme {
    var wellnessBackground: Color {
        self == .dark ? Color.themePrimaryDarkGreen : Color.themeLightAqua
    }
    
    var wellnessSurface: Color {
        self == .dark ? Color.themeDeepBlue : Color.white
    }
    
    var wellnessOnSurface: Color {
        self == .dark ? Color.white : Color.primary
    }
    
    var wellnessOnBackground: Color {
        self == .dark ? Color.white : Color.themePrimaryDarkGreen
    }
}

// MARK: - Color Utilities
struct ColorUtility {
    
    // MARK: - Color Generation
    static func randomWellnessColor() -> Color {
        let wellnessColors = [
            Color.themePrimaryDarkGreen,
            Color.themeTeal,
            Color.themeLavender,
            Color.themeDeepBlue
        ]
        return wellnessColors.randomElement() ?? Color.themeTeal
    }
    
    static func randomEmotionColor() -> Color {
        let emotionColors = [
            Color.emotionHappy,
            Color.emotionSad,
            Color.emotionAnxious,
            Color.emotionAngry,
            Color.emotionGrateful,
            Color.emotionPeaceful,
            Color.emotionStressed,
            Color.emotionExcited,
            Color.emotionTired,
            Color.emotionConfused
        ]
        return emotionColors.randomElement() ?? Color.emotionHappy
    }
    
    // MARK: - Color Analysis
    static func isLightColor(_ color: Color) -> Bool {
        // Simple heuristic - in a real app, you might want more sophisticated color analysis
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness > 0.5
    }
    
    static func contrastingTextColor(for backgroundColor: Color) -> Color {
        isLightColor(backgroundColor) ? .black : .white
    }
    
    // MARK: - Color Harmonies
    static func complementaryColor(for color: Color) -> Color {
        // Simple complementary color generation
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let complementaryHue = hue + 0.5
        if complementaryHue > 1.0 {
            return Color(hue: complementaryHue - 1.0, saturation: saturation, brightness: brightness)
        } else {
            return Color(hue: complementaryHue, saturation: saturation, brightness: brightness)
        }
    }
    
    static func analogousColors(for color: Color) -> [Color] {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let analogousHue1 = hue + 0.083
        let analogousHue2 = hue - 0.083
        
        return [
            Color(hue: analogousHue1 > 1.0 ? analogousHue1 - 1.0 : analogousHue1, saturation: saturation, brightness: brightness),
            Color(hue: analogousHue2 < 0 ? analogousHue2 + 1.0 : analogousHue2, saturation: saturation, brightness: brightness)
        ]
    }
}

// MARK: - Color Animation Extensions
extension Color {
    static func wellnessAnimation(from: Color, to: Color, duration: Double = 1.0) -> Animation {
        Animation.easeInOut(duration: duration)
    }
    
    func animateTo(_ color: Color, duration: Double = 1.0) -> some View {
        self.animation(Color.wellnessAnimation(from: self, to: color, duration: duration), value: color)
    }
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static func wellnessGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color.themePrimaryDarkGreen, Color.themeTeal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func conversationalGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color.themeDeepBlue, Color.themeLavender],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func emotionalGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color.themeLavender, Color.themeTeal],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
    }
    
    static func spiritualGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color.themeDeepBlue, Color.themePrimaryDarkGreen],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static func physicalGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color.themeTeal, Color.themePrimaryDarkGreen],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }
}

// MARK: - Previews
#Preview("Color Extensions") {
    VStack(spacing: WellnessSpacing.md) {
        HStack(spacing: WellnessSpacing.sm) {
            Circle()
                .fill(Color.wellnessPrimary)
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(Color.wellnessSecondary)
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(Color.wellnessAccent)
                .frame(width: 40, height: 40)
        }
        
        HStack(spacing: WellnessSpacing.sm) {
            Circle()
                .fill(Color.emotionHappy)
                .frame(width: 30, height: 30)
            
            Circle()
                .fill(Color.emotionAnxious)
                .frame(width: 30, height: 30)
            
            Circle()
                .fill(Color.emotionPeaceful)
                .frame(width: 30, height: 30)
        }
        
        VStack(spacing: WellnessSpacing.sm) {
            Rectangle()
                .fill(LinearGradient.wellnessGradient())
                .frame(height: 40)
            
            Rectangle()
                .fill(LinearGradient.conversationalGradient())
                .frame(height: 40)
            
            Rectangle()
                .fill(LinearGradient.emotionalGradient())
                .frame(height: 40)
        }
        .cornerRadius(WellnessSpacing.smallRadius)
    }
    .padding()
}
