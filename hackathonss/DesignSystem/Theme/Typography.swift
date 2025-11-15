import SwiftUI

// MARK: - Typography System
struct WellnessTypography {
    
    // MARK: - Font Families
    static let primaryFont = "SF Pro Display"
    static let secondaryFont = "SF Pro Text"
    
    // MARK: - Display Fonts
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // MARK: - Body Fonts
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    
    // MARK: - Specialized Fonts
    static let buttonText = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let cardTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let cardSubtitle = Font.system(size: 14, weight: .medium, design: .rounded)
    static let navigationTitle = Font.system(size: 17, weight: .semibold, design: .rounded)
}

// MARK: - Typography Extensions
extension Font {
    static let wellnessLargeTitle = WellnessTypography.largeTitle
    static let wellnessTitle1 = WellnessTypography.title1
    static let wellnessTitle2 = WellnessTypography.title2
    static let wellnessTitle3 = WellnessTypography.title3
    static let wellnessHeadline = WellnessTypography.headline
    static let wellnessBody = WellnessTypography.body
    static let wellnessCallout = WellnessTypography.callout
    static let wellnessSubheadline = WellnessTypography.subheadline
    static let wellnessFootnote = WellnessTypography.footnote
    static let wellnessCaption1 = WellnessTypography.caption1
    static let wellnessCaption2 = WellnessTypography.caption2
    static let wellnessButtonText = WellnessTypography.buttonText
    static let wellnessCardTitle = WellnessTypography.cardTitle
    static let wellnessCardSubtitle = WellnessTypography.cardSubtitle
    static let wellnessNavigationTitle = WellnessTypography.navigationTitle
}

// MARK: - Text Style Extensions
extension Text {
    func largeTitleStyle() -> Text {
        self.font(.wellnessLargeTitle)
            .foregroundColor(.themeOnBackground)
    }
    
    func title1Style() -> Text {
        self.font(.wellnessTitle1)
            .foregroundColor(.themeOnBackground)
    }
    
    func title2Style() -> Text {
        self.font(.wellnessTitle2)
            .foregroundColor(.themeOnBackground)
    }
    
    func title3Style() -> Text {
        self.font(.wellnessTitle3)
            .foregroundColor(.themeOnBackground)
    }
    
    func headlineStyle() -> Text {
        self.font(.wellnessHeadline)
            .foregroundColor(.themeOnBackground)
    }
    
    func bodyStyle() -> Text {
        self.font(.wellnessBody)
            .foregroundColor(.themeOnSurface)
    }
    
    func calloutStyle() -> Text {
        self.font(.wellnessCallout)
            .foregroundColor(.themeOnSurface)
    }
    
    func subheadlineStyle() -> Text {
        self.font(.wellnessSubheadline)
            .foregroundColor(.secondary)
    }
    
    func footnoteStyle() -> Text {
        self.font(.wellnessFootnote)
            .foregroundColor(.secondary)
    }
    
    func captionStyle() -> Text {
        self.font(.wellnessCaption1)
            .foregroundColor(.secondary)
    }
    
    func buttonTextStyle() -> Text {
        self.font(.wellnessButtonText)
    }
    
    func cardTitleStyle() -> Text {
        self.font(.wellnessCardTitle)
            .foregroundColor(.themeOnSurface)
    }
    
    func cardSubtitleStyle() -> Text {
        self.font(.wellnessCardSubtitle)
            .foregroundColor(.secondary)
    }
}
