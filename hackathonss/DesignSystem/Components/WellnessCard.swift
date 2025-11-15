import SwiftUI

// MARK: - Wellness Card Component
struct WellnessCard<Content: View>: View {
    let title: String?
    let subtitle: String?
    let icon: String?
    let iconColor: Color?
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowType: ShadowType
    let content: Content
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = WellnessSpacing.largeRadius,
        shadowType: ShadowType = .medium,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowType = shadowType
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: WellnessSpacing.sm) {
            if let icon = icon, let iconColor = iconColor {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 24))
                    
                    Spacer()
                }
            }
            
            if let title = title {
                Text(title)
                    .font(.wellnessCardTitle)
                    .foregroundColor(.themeOnSurface)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.wellnessCardSubtitle)
                    .foregroundColor(.secondary)
            }
            
            content
        }
        .padding(WellnessSpacing.cardPadding)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .shadow(
            color: shadowType.color,
            radius: shadowType.radius,
            x: shadowType.x,
            y: shadowType.y
        )
    }
}

// MARK: - Simple Wellness Card
struct SimpleWellnessCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color = .themeTeal,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: WellnessSpacing.md) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: WellnessSpacing.xs) {
                    Text(title)
                        .font(.wellnessCardTitle)
                        .foregroundColor(.themeOnSurface)
                    
                    Text(subtitle)
                        .font(.wellnessCardSubtitle)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            .padding(WellnessSpacing.cardPadding)
        }
        .background(Color.white)
        .cornerRadius(WellnessSpacing.largeRadius)
        .shadow(
            color: WellnessSpacing.mediumShadow.color,
            radius: WellnessSpacing.mediumShadow.radius,
            x: WellnessSpacing.mediumShadow.x,
            y: WellnessSpacing.mediumShadow.y
        )
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let trend: TrendType?
    
    init(
        title: String,
        value: String,
        icon: String,
        iconColor: Color = .themeTeal,
        trend: TrendType? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: WellnessSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20))
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: WellnessSpacing.xs) {
                        Image(systemName: trend.icon)
                            .foregroundColor(trend.color)
                            .font(.system(size: 12))
                        
                        Text(trend.value)
                            .font(.wellnessCaption1)
                            .foregroundColor(trend.color)
                    }
                }
            }
            
            Text(value)
                .font(.wellnessTitle2)
                .fontWeight(.bold)
                .foregroundColor(.themeOnSurface)
            
            Text(title)
                .font(.wellnessCardSubtitle)
                .foregroundColor(.secondary)
        }
        .padding(WellnessSpacing.cardPadding)
        .background(Color.white)
        .cornerRadius(WellnessSpacing.largeRadius)
        .shadow(
            color: WellnessSpacing.mediumShadow.color,
            radius: WellnessSpacing.mediumShadow.radius,
            x: WellnessSpacing.mediumShadow.x,
            y: WellnessSpacing.mediumShadow.y
        )
    }
}

// MARK: - Supporting Types
enum ShadowType {
    case none
    case light
    case medium
    case heavy
    
    var color: Color {
        switch self {
        case .none: return Color.clear
        case .light: return WellnessSpacing.lightShadow.color
        case .medium: return WellnessSpacing.mediumShadow.color
        case .heavy: return WellnessSpacing.heavyShadow.color
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .light: return WellnessSpacing.lightShadow.radius
        case .medium: return WellnessSpacing.mediumShadow.radius
        case .heavy: return WellnessSpacing.heavyShadow.radius
        }
    }
    
    var x: CGFloat {
        switch self {
        case .none, .light, .medium, .heavy: return 0
        }
    }
    
    var y: CGFloat {
        switch self {
        case .none: return 0
        case .light: return WellnessSpacing.lightShadow.y
        case .medium: return WellnessSpacing.mediumShadow.y
        case .heavy: return WellnessSpacing.heavyShadow.y
        }
    }
}

enum TrendType {
    case up(String)
    case down(String)
    case neutral(String)
    
    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return .themeSuccess
        case .down: return .themeError
        case .neutral: return .secondary
        }
    }
    
    var value: String {
        switch self {
        case .up(let value), .down(let value), .neutral(let value):
            return value
        }
    }
}

// MARK: - Previews
#Preview("Wellness Card") {
    WellnessCard(
        title: "Bienestar Físico",
        subtitle: "Monitorea tu actividad y salud",
        icon: "figure.walk",
        iconColor: .themeTeal
    ) {
        HStack {
            Text("5 días activos")
                .font(.wellnessBody)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Spacer()
            
            Text("Meta: 7")
                .font(.wellnessCaption1)
                .foregroundColor(.secondary)
        }
    }
    .padding()
}

#Preview("Simple Wellness Card") {
    SimpleWellnessCard(
        title: "Estado Emocional",
        subtitle: "Feliz y tranquilo",
        icon: "heart.fill",
        iconColor: .themeLavender
    )
    .padding()
}

#Preview("Metric Card") {
    MetricCard(
        title: "Pasos hoy",
        value: "8,432",
        icon: "figure.walk",
        iconColor: .themeTeal,
        trend: .up("12%")
    )
    .padding()
}
