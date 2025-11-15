import SwiftUI

// MARK: - Spacing System
struct WellnessSpacing {
    
    // MARK: - Base Spacing
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
    
    // MARK: - Component Spacing
    static let cardPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 12
    static let buttonPadding: CGFloat = 16
    static let iconTextSpacing: CGFloat = 8
    static let listRowSpacing: CGFloat = 8
    
    // MARK: - Layout Spacing
    static let screenPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 16
    static let gridSpacing: CGFloat = 12
    static let stackSpacing: CGFloat = 16
    
    // MARK: - Corner Radius
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 16
    static let buttonRadius: CGFloat = 25
    static let cardRadius: CGFloat = 16
    
    // MARK: - Shadow
    static let lightShadow = (color: Color.black.opacity(0.05), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
    static let mediumShadow = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    static let heavyShadow = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
}

// MARK: - Spacing Extensions
extension CGFloat {
    static let wellnessXS = WellnessSpacing.xs
    static let wellnessSM = WellnessSpacing.sm
    static let wellnessMD = WellnessSpacing.md
    static let wellnessLG = WellnessSpacing.lg
    static let wellnessXL = WellnessSpacing.xl
    static let wellnessXXL = WellnessSpacing.xxl
    static let wellnessXXXL = WellnessSpacing.xxxl
}

// MARK: - Spacing View Modifiers
extension View {
    func sectionSpacing() -> some View {
        self.padding(.vertical, WellnessSpacing.sectionSpacing)
    }
    
    func itemSpacing() -> some View {
        self.padding(.vertical, WellnessSpacing.itemSpacing)
    }
}

// MARK: - Spacing Utility Functions
struct SpacingUtility {
    static func getSpacing(for size: SpacingSize) -> CGFloat {
        switch size {
        case .xs: return WellnessSpacing.xs
        case .sm: return WellnessSpacing.sm
        case .md: return WellnessSpacing.md
        case .lg: return WellnessSpacing.lg
        case .xl: return WellnessSpacing.xl
        case .xxl: return WellnessSpacing.xxl
        case .xxxl: return WellnessSpacing.xxxl
        }
    }
    
    static func getCornerRadius(for size: CornerRadiusSize) -> CGFloat {
        switch size {
        case .small: return WellnessSpacing.smallRadius
        case .medium: return WellnessSpacing.mediumRadius
        case .large: return WellnessSpacing.largeRadius
        case .button: return WellnessSpacing.buttonRadius
        case .card: return WellnessSpacing.cardRadius
        }
    }
}

enum SpacingSize {
    case xs, sm, md, lg, xl, xxl, xxxl
}

enum CornerRadiusSize {
    case small, medium, large, button, card
}
