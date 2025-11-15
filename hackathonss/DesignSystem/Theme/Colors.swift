import SwiftUI

extension Color {
    // MARK: - Primary Color Palette
    static let themePrimaryDarkGreen = Color(hex: "#005233")
    static let themeTeal = Color(hex: "#2FA4B8")
    static let themeLightAqua = Color(hex: "#C3EDF4")
    static let themeLavender = Color(hex: "#B3A6FF")
    static let themeDeepBlue = Color(hex: "#252E89")
    
    // MARK: - Semantic Colors
    static let themeBackground = Color.themeLightAqua
    static let themeSurface = Color.white
    static let themeOnSurface = Color.primary
    static let themeOnBackground = Color.themePrimaryDarkGreen
    
    // MARK: - Status Colors
    static let themeSuccess = Color(hex: "#4CAF50")
    static let themeWarning = Color(hex: "#FFC107")
    static let themeError = Color(hex: "#F44336")
    static let themeInfo = Color(hex: "#2196F3")
    
    // MARK: - Gradient Colors
    static let themePrimaryGradient = LinearGradient(
        colors: [Color.themePrimaryDarkGreen, Color.themeTeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let themeConversationalGradient = LinearGradient(
        colors: [Color.themeDeepBlue, Color.themeLavender],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let themeWellnessGradient = LinearGradient(
        colors: [Color.themeTeal, Color.themeLightAqua],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}


// MARK: - Color Theme Protocol
protocol ColorTheme {
    static var primaryDarkGreen: Color { get }
    static var teal: Color { get }
    static var lightAqua: Color { get }
    static var lavender: Color { get }
    static var deepBlue: Color { get }
}

struct WellnessColorTheme: ColorTheme {
    static let primaryDarkGreen = Color.themePrimaryDarkGreen
    static let teal = Color.themeTeal
    static let lightAqua = Color.themeLightAqua
    static let lavender = Color.themeLavender
    static let deepBlue = Color.themeDeepBlue
}
