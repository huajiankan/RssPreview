//
//  ModernComponents.swift
//  RssPreviewer
//
//  Created by Codegen on 2024/12/25.
//

import SwiftUI

// MARK: - Modern Button Component
struct ModernButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let size: ButtonSize
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case destructive
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
    }
    
    init(_ title: String, style: ButtonStyle = .primary, size: ButtonSize = .medium, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(fontForSize)
                .fontWeight(.medium)
                .foregroundColor(foregroundColor)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(backgroundColor)
                .cornerRadius(DesignSystem.CornerRadius.sm)
                .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
                .animation(DesignSystem.Animation.quick, value: isPressed)
                .animation(DesignSystem.Animation.quick, value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
        .modernShadow(shadowForStyle)
    }
    
    private var fontForSize: Font {
        switch size {
        case .small: return DesignSystem.Typography.caption
        case .medium: return DesignSystem.Typography.body
        case .large: return DesignSystem.Typography.headline
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return DesignSystem.Spacing.sm
        case .medium: return DesignSystem.Spacing.md
        case .large: return DesignSystem.Spacing.lg
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small: return DesignSystem.Spacing.xs
        case .medium: return DesignSystem.Spacing.sm
        case .large: return DesignSystem.Spacing.md
        }
    }
    
    private var backgroundColor: Color {
        let baseColor: Color
        switch style {
        case .primary: baseColor = DesignSystem.Colors.primary
        case .secondary: baseColor = DesignSystem.Colors.backgroundSecondary
        case .tertiary: baseColor = Color.clear
        case .destructive: baseColor = DesignSystem.Colors.error
        }
        
        if isPressed {
            return baseColor.opacity(0.8)
        } else if isHovered {
            return baseColor.opacity(0.9)
        } else {
            return baseColor
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary, .tertiary: return DesignSystem.Colors.textPrimary
        }
    }
    
    private var shadowForStyle: Shadow {
        switch style {
        case .primary, .destructive: return DesignSystem.Shadows.small
        case .secondary: return DesignSystem.Shadows.small
        case .tertiary: return Shadow(color: .clear, radius: 0, x: 0, y: 0)
        }
    }
}

// MARK: - Modern Card Component
struct ModernCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadow: Shadow
    
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    
    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.md,
        shadow: Shadow = DesignSystem.Shadows.card,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(cardBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(DesignSystem.Animation.smooth, value: isHovered)
            .modernShadow(isHovered ? enhancedShadow : shadow)
            .onHover { hovering in
                isHovered = hovering
            }
    }
    
    private var cardBackground: Color {
        DesignSystem.Colors.adaptiveCardBackground(colorScheme)
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
    
    private var enhancedShadow: Shadow {
        Shadow(
            color: shadow.color,
            radius: shadow.radius * 1.5,
            x: shadow.x,
            y: shadow.y * 1.5
        )
    }
}

// MARK: - Modern Search Bar
struct ModernSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onClear: (() -> Void)?
    
    @State private var isFocused = false
    @Environment(\.colorScheme) var colorScheme
    
    init(_ placeholder: String, text: Binding<String>, onClear: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.onClear = onClear
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(DesignSystem.Typography.body)
                .onFocusChange { focused in
                    withAnimation(DesignSystem.Animation.quick) {
                        isFocused = focused
                    }
                }
            
            if !text.isEmpty {
                Button(action: {
                    withAnimation(DesignSystem.Animation.quick) {
                        text = ""
                        onClear?()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(searchBackground)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
        )
        .animation(DesignSystem.Animation.quick, value: isFocused)
    }
    
    private var searchBackground: Color {
        colorScheme == .dark ? Color(NSColor.controlBackgroundColor) : Color(NSColor.textBackgroundColor)
    }
    
    private var borderColor: Color {
        if isFocused {
            return DesignSystem.Colors.primary
        } else {
            return colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
        }
    }
}

// MARK: - Modern Loading View
struct ModernLoadingView: View {
    let message: String
    @State private var rotation = 0.0
    @Environment(\.colorScheme) var colorScheme
    
    init(_ message: String = "加载中...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(DesignSystem.Colors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(rotation))
                    .animation(
                        Animation.linear(duration: 1.0).repeatForever(autoreverses: false),
                        value: rotation
                    )
            }
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.adaptiveBackground(colorScheme))
        .onAppear {
            rotation = 360
        }
    }
}

// MARK: - Modern Tag View
struct ModernTag: View {
    let text: String
    let color: Color
    let size: TagSize
    
    enum TagSize {
        case small
        case medium
        case large
    }
    
    init(_ text: String, color: Color = DesignSystem.Colors.primary, size: TagSize = .medium) {
        self.text = text
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(fontForSize)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(color)
            .cornerRadius(DesignSystem.CornerRadius.xs)
    }
    
    private var fontForSize: Font {
        switch size {
        case .small: return DesignSystem.Typography.caption2
        case .medium: return DesignSystem.Typography.caption
        case .large: return DesignSystem.Typography.footnote
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return DesignSystem.Spacing.xs
        case .medium: return DesignSystem.Spacing.sm
        case .large: return DesignSystem.Spacing.md
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 2
        case .medium: return DesignSystem.Spacing.xs
        case .large: return DesignSystem.Spacing.sm
        }
    }
}

// MARK: - Helper Extensions
extension View {
    func onFocusChange(_ action: @escaping (Bool) -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: NSControl.textDidBeginEditingNotification)) { _ in
            action(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSControl.textDidEndEditingNotification)) { _ in
            action(false)
        }
    }
    
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

