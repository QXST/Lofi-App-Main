//
//  AppTheme.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary brand colors
        static let primary = Color(red: 0.5, green: 0.6, blue: 1.0)
        static let primaryDark = Color(red: 0.4, green: 0.5, blue: 0.9)

        // Background gradients
        static let backgroundTop = Color(red: 0.15, green: 0.15, blue: 0.2)
        static let backgroundBottom = Color(red: 0.1, green: 0.1, blue: 0.15)

        // Card backgrounds
        static let cardLight = Color.white.opacity(0.05)
        static let cardMedium = Color.white.opacity(0.1)
        static let cardDark = Color.white.opacity(0.15)

        // Text colors
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)

        // Cloud theme
        static let cloudGradientStart = Color(red: 0.5, green: 0.6, blue: 1.0)
        static let cloudGradientEnd = Color(red: 0.4, green: 0.5, blue: 0.9)
    }

    // MARK: - Gradients
    struct Gradients {
        static var background: LinearGradient {
            LinearGradient(
                colors: [Colors.backgroundTop, Colors.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        }

        static var cloud: LinearGradient {
            LinearGradient(
                colors: [Colors.cloudGradientStart, Colors.cloudGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static var primaryButton: LinearGradient {
            LinearGradient(
                colors: [Colors.primary, Colors.primaryDark],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        static let large = Shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Typography
    struct Typography {
        static func largeTitle(weight: Font.Weight = .bold) -> Font {
            .system(size: 32, weight: weight)
        }

        static func title(weight: Font.Weight = .bold) -> Font {
            .system(size: 24, weight: weight)
        }

        static func headline(weight: Font.Weight = .semibold) -> Font {
            .system(size: 18, weight: weight)
        }

        static func body(weight: Font.Weight = .regular) -> Font {
            .system(size: 16, weight: weight)
        }

        static func callout(weight: Font.Weight = .medium) -> Font {
            .system(size: 14, weight: weight)
        }

        static func caption(weight: Font.Weight = .regular) -> Font {
            .system(size: 12, weight: weight)
        }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardLight)
            )
    }

    func cardStyleActive() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardMedium)
            )
    }
}
