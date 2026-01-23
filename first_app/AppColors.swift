import SwiftUI

struct AppColors {
    // Use simple colors without the complex extension
    static let backgroundColor = Color(UIColor.systemBackground)
    static let textColor = Color(UIColor.label)
    static let secondaryTextColor = Color(UIColor.secondaryLabel)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let borderColor = Color(UIColor.separator)
}

// Or if you want custom colors, use this simpler approach:
struct CustomColors {
    static let lightBackground = Color.white
    static let darkBackground = Color.black
    static let lightText = Color.black
    static let darkText = Color.white
    static let lightSecondaryText = Color.gray
    static let darkSecondaryText = Color.gray.opacity(0.8)
    static let lightCardBackground = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let darkCardBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let lightBorder = Color(red: 0.88, green: 0.88, blue: 0.88)
    static let darkBorder = Color(red: 0.22, green: 0.22, blue: 0.23)
}

// Simple adaptive color extension
extension Color {
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// Alternative: Use system colors directly in your views
extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let systemLabel = Color(UIColor.label)
    static let systemSecondaryLabel = Color(UIColor.secondaryLabel)
    static let systemTertiaryLabel = Color(UIColor.tertiaryLabel)
    static let systemFill = Color(UIColor.systemFill)
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
}
