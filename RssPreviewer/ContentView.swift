//
//  ContentView.swift
//  RssPreviewer
//
//  Created by KrabsWang on 2024/9/1.
//  Updated by Codegen on 2025/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RssViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var windowConfigured = false
    
    var body: some View {
        NavigationView {
            modernMainView
        }
        .navigationViewStyle(DefaultNavigationViewStyle())
        .background(backgroundGradient)
        .onAppear {
            configureWindow()
        }
    }
    
    private var modernMainView: some View {
        VStack(spacing: 0) {
            // Modern Header
            modernHeader
            
            // Main Content
            RssListView(viewModel: viewModel)
                .background(DesignSystem.Colors.adaptiveBackground(colorScheme))
        }
        .background(backgroundGradient)
    }
    
    private var modernHeader: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                // App Title with modern styling
                VStack(alignment: .leading, spacing: 4) {
                    Text("RSS Preview")
                        .font(DesignSystem.Typography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(headerTitleGradient)
                    
                    Text("现代化的 RSS 阅读体验")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Modern status indicator
                modernStatusIndicator
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.md)
            
            // Subtle divider
            Rectangle()
                .fill(DesignSystem.Colors.cardBorder)
                .frame(height: 0.5)
                .opacity(0.5)
        }
        .background(headerBackground)
    }
    
    private var modernStatusIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Connection status
            Circle()
                .fill(viewModel.isLoading ? DesignSystem.Colors.warning : DesignSystem.Colors.success)
                .frame(width: 8, height: 8)
                .scaleEffect(viewModel.isLoading ? 1.2 : 1.0)
                .animation(
                    viewModel.isLoading ? 
                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : 
                    .default,
                    value: viewModel.isLoading
                )
            
            Text(viewModel.isLoading ? "同步中" : "已连接")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.backgroundSecondary)
                .opacity(0.8)
        )
    }
    
    private var headerTitleGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.accent],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                DesignSystem.Colors.adaptiveBackground(colorScheme),
                DesignSystem.Colors.backgroundSecondary
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var headerBackground: some View {
        Rectangle()
            .fill(
                colorScheme == .dark ? 
                Color.black.opacity(0.3) : 
                Color.white.opacity(0.8)
            )
            .background(.ultraThinMaterial)
    }
    
    private func configureWindow() {
        guard !windowConfigured else { return }
        
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                // Modern window configuration
                window.setContentSize(NSSize(width: 800, height: 900)) // Larger, more modern size
                window.center()
                
                // Modern window styling
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                
                // Set minimum size
                window.minSize = NSSize(width: 600, height: 700)
                
                windowConfigured = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        ContentView()
            .preferredColorScheme(.dark)
    }
}
