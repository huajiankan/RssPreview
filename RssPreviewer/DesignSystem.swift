//
//  DesignSystem.swift
//  RssPreviewer
//
//  Created by Codegen on 2024/12/25.
//

import SwiftUI

// MARK: - 设计系统
struct DesignSystem {
    
    // MARK: - 颜色方案
    struct Colors {
        // 主色调
        static let primary = Color(red: 0.2, green: 0.6, blue: 1.0) // 现代蓝色
        static let primaryDark = Color(red: 0.1, green: 0.4, blue: 0.8)
        
        // 背景色
        static let backgroundPrimary = Color(NSColor.controlBackgroundColor)
        static let backgroundSecondary = Color(NSColor.windowBackgroundColor)
        static let backgroundCard = Color(NSColor.controlBackgroundColor)
        
        // 文字颜色
        static let textPrimary = Color(NSColor.labelColor)
        static let textSecondary = Color(NSColor.secondaryLabelColor)
        static let textTertiary = Color(NSColor.tertiaryLabelColor)
        
        // 强调色
        static let accent = Color(red: 0.3, green: 0.7, blue: 0.9)
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let error = Color(red: 1.0, green: 0.3, blue: 0.3)
        
        // 边框和分割线
        static let border = Color(NSColor.separatorColor)
        static let borderLight = Color(NSColor.separatorColor).opacity(0.3)
        
        // 悬停和选中状态
        static let hover = Color(NSColor.controlAccentColor).opacity(0.1)
        static let selected = Color(NSColor.controlAccentColor)
        static let selectedText = Color.white
    }
    
    // MARK: - 字体系统
    struct Typography {
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
        static let title = Font.system(size: 22, weight: .semibold, design: .default)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 15, weight: .regular, design: .default)
        static let callout = Font.system(size: 14, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 13, weight: .regular, design: .default)
        static let footnote = Font.system(size: 12, weight: .regular, design: .default)
        static let caption = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - 间距系统
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - 圆角系统
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }
    
    // MARK: - 阴影系统
    struct Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let large = (color: Color.black.opacity(0.2), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    }
}

// MARK: - 自定义修饰符
extension View {
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.backgroundCard)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(
                color: DesignSystem.Shadow.small.color,
                radius: DesignSystem.Shadow.small.radius,
                x: DesignSystem.Shadow.small.x,
                y: DesignSystem.Shadow.small.y
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.CornerRadius.small)
            .font(DesignSystem.Typography.callout.weight(.medium))
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.backgroundSecondary)
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .cornerRadius(DesignSystem.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .font(DesignSystem.Typography.callout.weight(.medium))
    }
}

