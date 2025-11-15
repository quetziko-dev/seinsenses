import SwiftUI

// MARK: - View Modifiers for Wellness App
extension View {
    
    // MARK: - Card Modifiers
    func wellnessCardStyle() -> some View {
        self.wellnessCard()
    }
    
    // MARK: - Background Modifiers
    func wellnessBackground() -> some View {
        self.background(Color.themeLightAqua)
    }
    
    func gradientBackground(_ gradientType: GradientType = .wellness) -> some View {
        self.background(
            LinearGradient(
                colors: gradientType.colors,
                startPoint: gradientType.startPoint,
                endPoint: gradientType.endPoint
            )
        )
    }
    
    // MARK: - Padding Modifiers
    func screenPadding() -> some View {
        self.padding(WellnessSpacing.screenPadding)
    }
    
    func cardPadding() -> some View {
        self.padding(WellnessSpacing.cardPadding)
    }
    
    func sectionPadding() -> some View {
        self.padding(WellnessSpacing.sectionSpacing)
    }
    
    // MARK: - Text Styling Modifiers
    func wellnessTitle() -> some View {
        self.font(.wellnessTitle2)
            .fontWeight(.bold)
            .foregroundColor(.themeOnBackground)
    }
    
    func wellnessHeadline() -> some View {
        self.font(.wellnessHeadline)
            .foregroundColor(.themePrimaryDarkGreen)
    }
    
    func wellnessBodyText() -> some View {
        self.font(.wellnessBody)
            .foregroundColor(.themeOnSurface)
    }
    
    func wellnessCaption() -> some View {
        self.font(.wellnessCaption1)
            .foregroundColor(.secondary)
    }
    
    // MARK: - Button Styling Modifiers
    func primaryButtonStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
    
    func gradientButtonStyle(_ gradientType: GradientType = .wellness) -> some View {
        self.buttonStyle(
            GradientButtonStyle(
                gradient: LinearGradient(
                    colors: gradientType.colors,
                    startPoint: gradientType.startPoint,
                    endPoint: gradientType.endPoint
                )
            )
        )
    }
    
    func textButtonStyle() -> some View {
        self.buttonStyle(TextButtonStyle())
    }
    
    // MARK: - Animation Modifiers
    func wellnessBounce() -> some View {
        self.scaleEffect(1.0)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    // Animation handled by gesture
                }
            }
    }
    
    func wellnessFadeIn() -> some View {
        self.opacity(0.0)
            .animation(.easeInOut(duration: 0.5), value: false)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    // Fade in animation
                }
            }
    }
    
    func wellnessSlideIn(from edge: Edge = .bottom) -> some View {
        self.offset(y: edge == .bottom ? 50 : (edge == .top ? -50 : 0))
            .offset(x: edge == .leading ? 50 : (edge == .trailing ? -50 : 0))
            .animation(.easeInOut(duration: 0.5), value: false)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    // Slide in animation
                }
            }
    }
    
    // MARK: - Layout Modifiers
    func wellnessStack(spacing: CGFloat = WellnessSpacing.stackSpacing) -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    func wellnessHStack(spacing: CGFloat = WellnessSpacing.stackSpacing) -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    func wellnessVStack(spacing: CGFloat = WellnessSpacing.stackSpacing) -> some View {
        self.frame(maxWidth: .infinity)
    }
    
    // MARK: - Shadow Modifiers
    func wellnessShadow(_ type: ShadowType = .medium) -> some View {
        self.shadow(
            color: type.color,
            radius: type.radius,
            x: type.x,
            y: type.y
        )
    }
    
    func lightWellnessShadow() -> some View {
        self.wellnessShadow(.light)
    }
    
    func mediumWellnessShadow() -> some View {
        self.wellnessShadow(.medium)
    }
    
    func heavyWellnessShadow() -> some View {
        self.wellnessShadow(.heavy)
    }
    
    // MARK: - Corner Radius Modifiers
    func wellnessCornerRadius(_ radius: CornerRadiusSize = .medium) -> some View {
        self.cornerRadius(SpacingUtility.getCornerRadius(for: radius))
    }
    
    func smallWellnessRadius() -> some View {
        self.wellnessCornerRadius(.small)
    }
    
    func mediumWellnessRadius() -> some View {
        self.wellnessCornerRadius(.medium)
    }
    
    func largeWellnessRadius() -> some View {
        self.wellnessCornerRadius(.large)
    }
    
    // MARK: - Border Modifiers
    func wellnessBorder(
        color: Color = .themeTeal,
        width: CGFloat = 1,
        cornerRadius: CornerRadiusSize = .medium
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: SpacingUtility.getCornerRadius(for: cornerRadius))
                .stroke(color, lineWidth: width)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpacingUtility.getCornerRadius(for: cornerRadius)))
    }
    
    // MARK: - Accessibility Modifiers
    func wellnessAccessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(label)
    }
    
    func wellnessAccessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(hint)
    }
    
    func wellnessAccessibilityAction(_ action: @escaping () -> Void) -> some View {
        self.accessibilityAction(.default) {
            action()
        }
    }
}

// MARK: - Custom View Modifiers
struct WellnessCardModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowType: ShadowType
    
    func body(content: Content) -> some View {
        content
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

struct WellnessBackgroundModifier: ViewModifier {
    let gradientType: GradientType
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: gradientType.colors,
                    startPoint: gradientType.startPoint,
                    endPoint: gradientType.endPoint
                )
            )
    }
}

struct WellnessTextModifier: ViewModifier {
    let style: TextStyle
    
    enum TextStyle {
        case title, headline, body, caption
    }
    
    func body(content: Content) -> some View {
        switch style {
        case .title:
            content
                .font(.wellnessTitle2)
                .fontWeight(.bold)
                .foregroundColor(.themeOnBackground)
        case .headline:
            content
                .font(.wellnessHeadline)
                .foregroundColor(.themePrimaryDarkGreen)
        case .body:
            content
                .font(.wellnessBody)
                .foregroundColor(.themeOnSurface)
        case .caption:
            content
                .font(.wellnessCaption1)
                .foregroundColor(.secondary)
        }
    }
}

struct WellnessAnimationModifier: ViewModifier {
    let animationType: AnimationType
    @State private var isAnimated = false
    
    enum AnimationType {
        case bounce, fadeIn, slideIn(from: Edge)
    }
    
    func body(content: Content) -> some View {
        switch animationType {
        case .bounce:
            content
                .scaleEffect(isAnimated ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimated
                )
                .onAppear {
                    isAnimated = true
                }
        case .fadeIn:
            content
                .opacity(isAnimated ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.5), value: isAnimated)
                .onAppear {
                    isAnimated = true
                }
        case .slideIn(let edge):
            content
                .offset(
                    x: edge == .leading ? (isAnimated ? 0 : 50) : (edge == .trailing ? (isAnimated ? 0 : -50) : 0),
                    y: edge == .top ? (isAnimated ? 0 : 50) : (edge == .bottom ? (isAnimated ? 0 : -50) : 0)
                )
                .animation(.easeInOut(duration: 0.5), value: isAnimated)
                .onAppear {
                    isAnimated = true
                }
        }
    }
}

// MARK: - Additional Extension Methods
extension View {
    func wellnessCard(
        backgroundColor: Color = .white,
        cornerRadius: CornerRadiusSize = .large,
        shadowType: ShadowType = .medium
    ) -> some View {
        self.modifier(
            WellnessCardModifier(
                backgroundColor: backgroundColor,
                cornerRadius: SpacingUtility.getCornerRadius(for: cornerRadius),
                shadowType: shadowType
            )
        )
    }
    
    func wellnessGradientBackground(_ gradientType: GradientType = .wellness) -> some View {
        self.modifier(WellnessBackgroundModifier(gradientType: gradientType))
    }
    
    func wellnessTextStyle(_ style: WellnessTextModifier.TextStyle) -> some View {
        self.modifier(WellnessTextModifier(style: style))
    }
    
    func wellnessAnimation(_ type: WellnessAnimationModifier.AnimationType) -> some View {
        self.modifier(WellnessAnimationModifier(animationType: type))
    }
}

// MARK: - Conditional Modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func modifier<T: ViewModifier>(_ modifier: T?, apply: Bool) -> some View {
        if let modifier = modifier, apply {
            self.modifier(modifier)
        } else {
            self
        }
    }
}

// MARK: - Preview Helper
extension View {
    func previewWithAllModifiers() -> some View {
        self
            .wellnessCard()
            .wellnessTextStyle(.body)
            .wellnessAnimation(.fadeIn)
            .screenPadding()
    }
}

// MARK: - Previews
#Preview("View Modifiers") {
    VStack(spacing: WellnessSpacing.lg) {
        Text("Título Wellness")
            .wellnessTextStyle(.title)
        
        Text("Headline Wellness")
            .wellnessTextStyle(.headline)
        
        Text("Body Text Wellness")
            .wellnessTextStyle(.body)
        
        Text("Caption Wellness")
            .wellnessTextStyle(.caption)
        
        VStack {
            Text("Card con Modifiers")
                .wellnessTextStyle(.headline)
                .padding()
        }
        .wellnessCard(backgroundColor: .white, cornerRadius: .large)
        
        VStack {
            Text("Animated Card")
                .wellnessTextStyle(.body)
                .padding()
        }
        .wellnessCard(backgroundColor: .themeTeal, cornerRadius: .medium)
        .wellnessAnimation(.bounce)
    }
    .padding()
    .wellnessBackground()
}
