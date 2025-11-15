import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(
        backgroundColor: Color = .themeTeal,
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = WellnessSpacing.buttonRadius
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.wellnessButtonText)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, WellnessSpacing.buttonPadding)
            .padding(.vertical, WellnessSpacing.md)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: WellnessSpacing.mediumShadow.color,
                radius: WellnessSpacing.mediumShadow.radius,
                x: WellnessSpacing.mediumShadow.x,
                y: WellnessSpacing.mediumShadow.y
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let borderColor: Color
    let cornerRadius: CGFloat
    
    init(
        backgroundColor: Color = .white,
        foregroundColor: Color = .themeTeal,
        borderColor: Color = .themeTeal,
        cornerRadius: CGFloat = WellnessSpacing.buttonRadius
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.wellnessButtonText)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, WellnessSpacing.buttonPadding)
            .padding(.vertical, WellnessSpacing.md)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Gradient Button Style
struct GradientButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let foregroundColor: Color
    let cornerRadius: CGFloat
    
    init(
        gradient: LinearGradient = Color.themePrimaryGradient,
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = WellnessSpacing.buttonRadius
    ) {
        self.gradient = gradient
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.wellnessButtonText)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, WellnessSpacing.buttonPadding)
            .padding(.vertical, WellnessSpacing.md)
            .background(gradient)
            .cornerRadius(cornerRadius)
            .shadow(
                color: WellnessSpacing.mediumShadow.color,
                radius: WellnessSpacing.mediumShadow.radius,
                x: WellnessSpacing.mediumShadow.x,
                y: WellnessSpacing.mediumShadow.y
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style
struct IconButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(
        backgroundColor: Color = .themeTeal,
        foregroundColor: Color = .white,
        size: CGFloat = 44,
        cornerRadius: CGFloat = WellnessSpacing.mediumRadius
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: WellnessSpacing.lightShadow.color,
                radius: WellnessSpacing.lightShadow.radius,
                x: WellnessSpacing.lightShadow.x,
                y: WellnessSpacing.lightShadow.y
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Text Button Style
struct TextButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let underline: Bool
    
    init(
        foregroundColor: Color = .themeTeal,
        underline: Bool = false
    ) {
        self.foregroundColor = foregroundColor
        self.underline = underline
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.wellnessButtonText)
            .foregroundColor(foregroundColor)
            .underline(underline)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Primary Button Component
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: PrimaryButtonStyle
    let isDisabled: Bool
    
    init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void,
        style: PrimaryButtonStyle = PrimaryButtonStyle(),
        isDisabled: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.style = style
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: WellnessSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
            }
        }
        .buttonStyle(style)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Secondary Button Component
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: SecondaryButtonStyle
    let isDisabled: Bool
    
    init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void,
        style: SecondaryButtonStyle = SecondaryButtonStyle(),
        isDisabled: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.style = style
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: WellnessSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
            }
        }
        .buttonStyle(style)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Icon Button Component
struct IconButton: View {
    let icon: String
    let action: () -> Void
    let style: IconButtonStyle
    let isDisabled: Bool
    
    init(
        icon: String,
        action: @escaping () -> Void,
        style: IconButtonStyle = IconButtonStyle(),
        isDisabled: Bool = false
    ) {
        self.icon = icon
        self.action = action
        self.style = style
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
        }
        .buttonStyle(style)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Previews
#Preview("Primary Button") {
    VStack(spacing: WellnessSpacing.md) {
        PrimaryButton(title: "Comenzar", icon: "play.fill") {
            print("Primary button tapped")
        }
        
        PrimaryButton(title: "Deshabilitado", icon: nil, action: {
            print("This won't be called")
        }, isDisabled: true)
        
        Button("Gradiente") {
            print("Gradient button tapped")
        }
        .buttonStyle(GradientButtonStyle())
    }
    .padding()
}

#Preview("Secondary Button") {
    VStack(spacing: WellnessSpacing.md) {
        SecondaryButton(title: "Cancelar", icon: "xmark") {
            print("Secondary button tapped")
        }
        
        SecondaryButton(
            title: "Personalizado",
            action: {},
            style: SecondaryButtonStyle(
                backgroundColor: .themeLightAqua,
                foregroundColor: .themeDeepBlue,
                borderColor: .themeDeepBlue
            )
        )
    }
    .padding()
}

#Preview("Icon Button") {
    HStack(spacing: WellnessSpacing.md) {
        IconButton(icon: "heart.fill") {
            print("Heart tapped")
        }
        
        IconButton(icon: "plus", action: {}, style: IconButtonStyle(backgroundColor: .themeLavender))
        
        IconButton(icon: "trash", action: {}, style: IconButtonStyle(backgroundColor: .themeError))
    }
    .padding()
}
