import SwiftUI

// MARK: - Mood Marble Component
struct MoodMarbleView: View {
    let marble: MoodMarble
    let size: MarbleSize
    let showIntensity: Bool
    let isAnimated: Bool
    
    init(
        marble: MoodMarble,
        size: MarbleSize = .medium,
        showIntensity: Bool = true,
        isAnimated: Bool = false
    ) {
        self.marble = marble
        self.size = size
        self.showIntensity = showIntensity
        self.isAnimated = isAnimated
    }
    
    var body: some View {
        ZStack {
            // Main marble
            Circle()
                .fill(Color(hex: marble.emotion.color))
                .frame(width: size.diameter, height: size.diameter)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 2,
                    x: 0,
                    y: 1
                )
            
            // Shine effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: size.diameter * 0.1,
                        endRadius: size.diameter * 0.4
                    )
                )
                .frame(width: size.diameter * 0.8, height: size.diameter * 0.8)
                .offset(x: -size.diameter * 0.1, y: -size.diameter * 0.1)
            
            // Intensity indicator
            if showIntensity && size != .small {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        IntensityIndicator(
                            intensity: marble.intensity,
                            size: size.intensityIndicatorSize
                        )
                    }
                }
                .frame(width: size.diameter, height: size.diameter)
            }
            
            // Emotion icon for larger sizes
            if size == .large || size == .extraLarge {
                Text(marble.emotion.icon)
                    .font(.system(size: size.iconSize))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .scaleEffect(isAnimated ? 1.1 : 1.0)
        .animation(
            isAnimated ?
            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
            .default,
            value: isAnimated
        )
    }
}

// MARK: - Intensity Indicator
struct IntensityIndicator: View {
    let intensity: Double
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index < Int(intensity * 3) ? Color.white : Color.white.opacity(0.3))
                    .frame(width: size, height: size)
            }
        }
    }
}

// MARK: - Mood Jar Visualization (Pixar Style)
struct MoodJarView: View {
    let marbles: [MoodMarble]
    let maxVisible: Int
    let isAnimated: Bool
    @State private var animatedMarbles: [AnimatedMarble] = []
    
    init(
        marbles: [MoodMarble],
        maxVisible: Int = 30,
        isAnimated: Bool = false
    ) {
        self.marbles = Array(marbles.suffix(maxVisible))
        self.maxVisible = maxVisible
        self.isAnimated = isAnimated
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Metallic lid with shine (at top)
                metallicLid
                    .zIndex(2)
                
                // Glass jar body with pseudo-3D effect
                ZStack {
                    // Main glass container
                    glassJarContainer
                    
                    // Animated marbles inside
                    animatedMarbleStack
                }
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 280, maxHeight: 340)
        .onAppear {
            initializeAnimatedMarbles()
        }
        .onChange(of: marbles.count) { _, _ in
            initializeAnimatedMarbles()
        }
    }
    
    private var glassJarContainer: some View {
        ZStack {
            // Main glass body - soft volumetric appearance
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            Color.white.opacity(0.75),
                            Color.white.opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Subtle inner gradient for depth
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color(hex: "#C3EDF4").opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    // Glass border for definition
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            // Light reflection on glass (top-left)
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .blur(radius: 2)
            
            // Subtle shadow inside for depth
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 2)
                .blur(radius: 3)
                .offset(y: 2)
        }
        .frame(width: 200, height: 260)
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var animatedMarbleStack: some View {
        ZStack {
            ForEach(animatedMarbles) { animMarble in
                PixarMarbleView(
                    marble: animMarble.marble,
                    offset: animMarble.offset,
                    scale: animMarble.scale,
                    isAnimated: isAnimated
                )
                // Add subtle shadow to marbles for glass integration
                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
            }
        }
        .frame(width: 180, height: 240)
        .clipped()
        .offset(y: 10)
    }
    
    private var metallicLid: some View {
        ZStack {
            // Lid base with soft metallic gradient
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.45),
                            Color.gray.opacity(0.28),
                            Color.gray.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Metallic shine overlay
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.clear,
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 1)
            
            // Lid edge definition
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        }
        .frame(width: 200, height: 32)
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
        .padding(.bottom, -4)
    }
    
    private func initializeAnimatedMarbles() {
        // Configuration for ordered stacking
        let marbleSize: CGFloat = 32
        let spacing: CGFloat = 4
        let jarWidth: CGFloat = 150 // Usable width inside jar
        let marblesPerRow = Int(jarWidth / (marbleSize + spacing))
        let startY: CGFloat = 80 // Start from bottom of jar
        
        animatedMarbles = marbles.enumerated().map { index, marble in
            // Calculate row and column for grid layout
            let row = index / marblesPerRow
            let col = index % marblesPerRow
            
            // Offset for hexagonal/brick pattern (alternate rows)
            let rowOffset: CGFloat = row % 2 == 0 ? 0 : (marbleSize + spacing) / 2
            
            // Calculate X position (centered in jar)
            let totalRowWidth = CGFloat(marblesPerRow) * (marbleSize + spacing)
            let startX = -totalRowWidth / 2 + (marbleSize + spacing) / 2
            let x = startX + CGFloat(col) * (marbleSize + spacing) + rowOffset
            
            // Calculate Y position (stack from bottom up)
            let y = startY - CGFloat(row) * (marbleSize + spacing)
            
            return AnimatedMarble(
                id: marble.id,
                marble: marble,
                offset: CGSize(width: x, height: y),
                scale: 1.0,
                bounceDelay: Double(index) * 0.05
            )
        }
    }
}

// MARK: - Glass Jar Shape
struct GlassJarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Rounded jar shape
        path.move(to: CGPoint(x: width * 0.1, y: 0))
        path.addLine(to: CGPoint(x: width * 0.9, y: 0))
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.15),
            control1: CGPoint(x: width * 0.95, y: 0),
            control2: CGPoint(x: width, y: height * 0.05)
        )
        path.addLine(to: CGPoint(x: width, y: height * 0.8))
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control1: CGPoint(x: width, y: height * 0.95),
            control2: CGPoint(x: width * 0.75, y: height)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.8),
            control1: CGPoint(x: width * 0.25, y: height),
            control2: CGPoint(x: 0, y: height * 0.95)
        )
        path.addLine(to: CGPoint(x: 0, y: height * 0.15))
        path.addCurve(
            to: CGPoint(x: width * 0.1, y: 0),
            control1: CGPoint(x: 0, y: height * 0.05),
            control2: CGPoint(x: width * 0.05, y: 0)
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Enhanced Pixar Style Marble with Emoji
struct PixarMarbleView: View {
    let marble: MoodMarble
    let offset: CGSize
    let scale: CGFloat
    let isAnimated: Bool
    
    @State private var bounceOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Main marble with solid gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: marble.emotion.color).opacity(0.95),
                            Color(hex: marble.emotion.color),
                            Color(hex: marble.emotion.color).opacity(0.8)
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 16
                    )
                )
                .frame(width: 32, height: 32)
            
            // Emoji overlay (solid design)
            Text(marble.emotion.icon)
                .font(.system(size: 20))
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            
            // Glass shine effect (more prominent)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.25, y: 0.25),
                        startRadius: 1,
                        endRadius: 12
                    )
                )
                .frame(width: 32, height: 32)
            
            // Strong specular highlight
            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .offset(x: -7, y: -7)
                .blur(radius: 0.5)
            
            // Glass edge reflection
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.clear,
                            Color.white.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 32, height: 32)
        }
        .shadow(color: Color.black.opacity(0.35), radius: 5, x: 2, y: 4)
        .shadow(color: Color(hex: marble.emotion.color).opacity(0.5), radius: 8, x: 0, y: 0)
        .scaleEffect(scale)
        .offset(x: offset.width, y: offset.height + bounceOffset)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0.5, y: 1, z: 0)
        )
        .onAppear {
            if isAnimated {
                // Very subtle breathing effect only
                withAnimation(
                    .easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
                ) {
                    bounceOffset = 1.5 // Minimal movement
                }
                
                // Single rotation on appear, then static
                withAnimation(.easeOut(duration: 0.6).delay(Double(marble.id.hashValue % 100) * 0.01)) {
                    rotation = Double.random(in: -15...15) // Small random tilt
                }
            }
        }
    }
}

// MARK: - Animated Marble Model
struct AnimatedMarble: Identifiable {
    let id: UUID
    let marble: MoodMarble
    let offset: CGSize
    let scale: CGFloat
    let bounceDelay: Double
}

// MARK: - Mood Legend
struct MoodLegend: View {
    let emotions: [EmotionType: Int]
    let style: LegendStyle
    
    init(emotions: [EmotionType: Int], style: LegendStyle = .compact) {
        self.emotions = emotions
        self.style = style
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: style.spacing) {
            ForEach(emotions.sorted(by: { $0.value > $1.value }), id: \.key) { emotion, count in
                MoodLegendRow(
                    emotion: emotion,
                    count: count,
                    style: style
                )
            }
        }
    }
}

// MARK: - Mood Legend Row
struct MoodLegendRow: View {
    let emotion: EmotionType
    let count: Int
    let style: LegendStyle
    
    var body: some View {
        HStack(spacing: style.itemSpacing) {
            // Mood marble
            MoodMarbleView(
                marble: MoodMarble(emotion: emotion, intensity: 0.7, position: MarblePosition()),
                size: style.marbleSize,
                showIntensity: false
            )
            
            // Emotion info
            VStack(alignment: .leading, spacing: 2) {
                Text(emotion.rawValue.capitalized)
                    .font(style.textFont)
                    .foregroundColor(.primary)
                
                if style.showPercentage {
                    Text("\(count) \(count == 1 ? "vez" : "veces")")
                        .font(style.captionFont)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Count or percentage
            if style.showCount {
                Text("×\(count)")
                    .font(style.captionFont)
                    .fontWeight(.medium)
                    .foregroundColor(.themePrimaryDarkGreen)
            }
        }
        .padding(.vertical, style.rowPadding)
    }
}

// MARK: - Marble Size
enum MarbleSize {
    case tiny
    case small
    case medium
    case large
    case extraLarge
    
    var diameter: CGFloat {
        switch self {
        case .tiny: return 8
        case .small: return 12
        case .medium: return 16
        case .large: return 24
        case .extraLarge: return 32
        }
    }
    
    var intensityIndicatorSize: CGFloat {
        switch self {
        case .tiny, .small: return 2
        case .medium: return 3
        case .large: return 4
        case .extraLarge: return 5
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .tiny, .small: return 0
        case .medium: return 8
        case .large: return 12
        case .extraLarge: return 16
        }
    }
}

// MARK: - Legend Style
enum LegendStyle {
    case compact
    case detailed
    case minimal
    
    var spacing: CGFloat {
        switch self {
        case .compact: return 8
        case .detailed: return 12
        case .minimal: return 4
        }
    }
    
    var itemSpacing: CGFloat {
        switch self {
        case .compact: return 8
        case .detailed: return 12
        case .minimal: return 6
        }
    }
    
    var marbleSize: MarbleSize {
        switch self {
        case .compact: return .small
        case .detailed: return .medium
        case .minimal: return .tiny
        }
    }
    
    var textFont: Font {
        switch self {
        case .compact: return .wellnessCaption1
        case .detailed: return .wellnessBody
        case .minimal: return .wellnessCaption2
        }
    }
    
    var captionFont: Font {
        switch self {
        case .compact: return .wellnessCaption2
        case .detailed: return .wellnessCaption1
        case .minimal: return .wellnessCaption2
        }
    }
    
    var showCount: Bool {
        switch self {
        case .compact, .detailed: return true
        case .minimal: return false
        }
    }
    
    var showPercentage: Bool {
        switch self {
        case .compact: return false
        case .detailed: return true
        case .minimal: return false
        }
    }
    
    var rowPadding: CGFloat {
        switch self {
        case .compact: return 2
        case .detailed: return 4
        case .minimal: return 1
        }
    }
}

// MARK: - Mood Trend Chart
struct MoodTrendChart: View {
    let marbles: [MoodMarble]
    let days: Int
    
    init(marbles: [MoodMarble], days: Int = 7) {
        self.marbles = Array(marbles.suffix(days))
        self.days = days
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: WellnessSpacing.sm) {
            Text("Tendencia de \(days) días")
                .font(.wellnessCardSubtitle)
                .foregroundColor(.secondary)
            
            HStack(alignment: .center, spacing: WellnessSpacing.xs) {
                ForEach(0..<days, id: \.self) { dayIndex in
                    VStack(spacing: WellnessSpacing.xs) {
                        if dayIndex < marbles.count {
                            MoodMarbleView(
                                marble: marbles[dayIndex],
                                size: .tiny,
                                showIntensity: false
                            )
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        
                        Text(dayLabel(for: dayIndex))
                            .font(.wellnessCaption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(WellnessSpacing.mediumRadius)
        .shadow(
            color: WellnessSpacing.lightShadow.color,
            radius: WellnessSpacing.lightShadow.radius,
            x: WellnessSpacing.lightShadow.x,
            y: WellnessSpacing.lightShadow.y
        )
    }
    
    private func dayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        
        if index == days - 1 {
            return "Hoy"
        } else if index == days - 2 {
            return "Ayer"
        } else {
            let date = calendar.date(byAdding: .day, value: -(days - 1 - index), to: today) ?? today
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date).uppercased()
        }
    }
}

// MARK: - Previews
#Preview("Mood Marble") {
    VStack(spacing: WellnessSpacing.md) {
        HStack(spacing: WellnessSpacing.md) {
            MoodMarbleView(
                marble: MoodMarble(emotion: .happy, intensity: 0.8, position: MarblePosition()),
                size: .tiny
            )
            
            MoodMarbleView(
                marble: MoodMarble(emotion: .anxious, intensity: 0.6, position: MarblePosition()),
                size: .small
            )
            
            MoodMarbleView(
                marble: MoodMarble(emotion: .grateful, intensity: 0.9, position: MarblePosition()),
                size: .medium,
                isAnimated: true
            )
            
            MoodMarbleView(
                marble: MoodMarble(emotion: .peaceful, intensity: 0.7, position: MarblePosition()),
                size: .large
            )
        }
        
        MoodMarbleView(
            marble: MoodMarble(emotion: .excited, intensity: 1.0, position: MarblePosition()),
            size: .extraLarge,
            isAnimated: true
        )
    }
    .padding()
}

#Preview("Mood Jar") {
    let marbles = [
        MoodMarble(emotion: .happy, intensity: 0.8, position: MarblePosition()),
        MoodMarble(emotion: .grateful, intensity: 0.9, position: MarblePosition()),
        MoodMarble(emotion: .anxious, intensity: 0.4, position: MarblePosition()),
        MoodMarble(emotion: .peaceful, intensity: 0.7, position: MarblePosition()),
        MoodMarble(emotion: .excited, intensity: 1.0, position: MarblePosition()),
        MoodMarble(emotion: .sad, intensity: 0.3, position: MarblePosition())
    ]
    
    VStack(spacing: WellnessSpacing.lg) {
        MoodJarView(marbles: marbles, isAnimated: true)
        
        MoodLegend(
            emotions: Dictionary(grouping: marbles, by: { $0.emotion }).mapValues { $0.count },
            style: .detailed
        )
        
        MoodTrendChart(marbles: marbles, days: 7)
    }
    .padding()
}
