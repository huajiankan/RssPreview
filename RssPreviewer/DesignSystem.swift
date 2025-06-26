//
//  DesignSystem.swift
//  RssPreviewer
//
//  Created by Codegen on 2025/6/25.
//

import SwiftUI

// MARK: - Modern Design System

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color.blue
        static let primaryLight = Color.blue.opacity(0.1)
        static let primaryDark = Color.blue.opacity(0.8)
        
        // Accent Colors
        static let accent = Color.orange
        static let accentLight = Color.orange.opacity(0.1)
        
        // Background Colors
        static let backgroundPrimary = Color(NSColor.controlBackgroundColor)
        static let backgroundSecondary = Color(NSColor.windowBackgroundColor)
        static let backgroundTertiary = Color(NSColor.underPageBackgroundColor)
        
        // Card Colors
        static let cardBackground = Color(NSColor.controlBackgroundColor)
        static let cardBorder = Color(NSColor.separatorColor)
        
        // Text Colors
        static let textPrimary = Color(NSColor.labelColor)
        static let textSecondary = Color(NSColor.secondaryLabelColor)
        static let textTertiary = Color(NSColor.tertiaryLabelColor)
        
        // Status Colors
        static let success = Color.green
        static let warning = Color.yellow
        static let error = Color.red
        static let info = Color.blue
        
        // Gradients
        static let primaryGradient = LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardGradient = LinearGradient(
            colors: [Color.white.opacity(0.1), Color.clear],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let backgroundGradient = LinearGradient(
            colors: [Color(NSColor.windowBackgroundColor), Color(NSColor.controlBackgroundColor)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.medium)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline.weight(.semibold)
        static let subheadline = Font.subheadline.weight(.medium)
        static let body = Font.body
        static let bodyMedium = Font.body.weight(.medium)
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2
        static let footnote = Font.footnote
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let medium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = Shadow(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
        
        static let card = Shadow(
            color: Color.black.opacity(0.08),
            radius: 12,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    func modernShadow(_ shadow: Shadow = DesignSystem.Shadows.medium) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func modernCard(padding: CGFloat = DesignSystem.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .modernShadow(DesignSystem.Shadows.card)
    }
    
    func modernButton() -> some View {
        self
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .modernShadow(DesignSystem.Shadows.small)
    }
    
    func modernTextField() -> some View {
        self
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(DesignSystem.Colors.cardBorder, lineWidth: 1)
            )
    }
    
    func hoverEffect() -> some View {
        self
            .scaleEffect(1.0)
            .animation(DesignSystem.Animation.quick, value: UUID())
            .onHover { isHovered in
                withAnimation(DesignSystem.Animation.quick) {
                    // Hover effect will be handled by individual components
                }
            }
    }
}

// MARK: - Color Scheme Extensions
extension DesignSystem.Colors {
    static func adaptiveBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(NSColor.windowBackgroundColor) : Color(NSColor.controlBackgroundColor)
    }
    
    static func adaptiveCardBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(NSColor.controlBackgroundColor) : Color.white
    }
    
    static func adaptiveText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color.black
    }
}
