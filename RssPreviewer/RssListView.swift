//
//  RssListView.swift
//  RssPreviewer
//
//  Created by KrabsWang on 2024/9/1.
//  Updated by Codegen on 2024/12/25.
//

import Foundation
import SwiftUI

struct RssListView: View {
    @ObservedObject var viewModel: RssViewModel
    @State private var selectedRssItem: RssItem?
    @State private var searchText: String = ""
    @State private var rssUrl: String = ""
    @State private var showSettingsSheet: Bool = false
    @State private var showErrorAlert: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern RSS Title Section
            modernTitleSection
            
            // Modern Search Bar
            modernSearchSection
            
            // Content Area
            contentArea
        }
        .background(DesignSystem.Colors.adaptiveBackground(colorScheme))
        .onAppear {
            if viewModel.rssItems.isEmpty {
                viewModel.fetchRssItems()
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            ModernSettingsSheet(
                rssUrl: $rssUrl,
                onSave: {
                    viewModel.rssUrl = rssUrl
                    viewModel.fetchRssItems()
                    showSettingsSheet = false
                },
                onCancel: {
                    showSettingsSheet = false
                }
            )
        }
        .alert("错误", isPresented: $showErrorAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            if newValue != nil {
                showErrorAlert = true
            }
        }
    }
    
    private var modernTitleSection: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.rssTitle.isEmpty ? "RSS 源" : viewModel.rssTitle)
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(2)
                
                if !viewModel.rssItems.isEmpty {
                    Text("\(viewModel.rssItems.count) 篇文章")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Modern Settings Button
            Button(action: {
                rssUrl = viewModel.rssUrl
                showSettingsSheet = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(width: 36, height: 36)
                    .background(DesignSystem.Colors.primaryLight)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .hoverEffect()
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
    }
    
    private var modernSearchSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ModernSearchBar(
                "搜索文章标题...",
                text: $searchText,
                onClear: {
                    searchText = ""
                }
            )
            
            // Search results info
            if !searchText.isEmpty {
                HStack {
                    Text("找到 \(filteredRssItems.count) 篇相关文章")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    private var contentArea: some View {
        Group {
            if viewModel.isLoading {
                ModernLoadingView("正在获取最新内容...")
            } else if filteredRssItems.isEmpty {
                emptyStateView
            } else {
                modernRssListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(searchText.isEmpty ? "暂无内容" : "���找到相关文章")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Text(searchText.isEmpty ? "请检查 RSS 源或稍后重试" : "尝试使用其他关键词搜索")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty {
                ModernButton("重新加载", style: .secondary) {
                    viewModel.fetchRssItems()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.xl)
    }
    
    private var modernRssListView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(filteredRssItems) { item in
                    ModernRssItemView(
                        item: item,
                        isSelected: item == selectedRssItem,
                        onTap: {
                            withAnimation(DesignSystem.Animation.smooth) {
                                selectedRssItem = selectedRssItem == item ? nil : item
                            }
                        },
                        onLinkTap: {
                            if let url = URL(string: item.link) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .animation(DesignSystem.Animation.smooth, value: filteredRssItems.count)
    }
    
    var filteredRssItems: [RssItem] {
        if searchText.isEmpty {
            return viewModel.rssItems
        } else {
            return viewModel.rssItems.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct RssListItemView: View {
    let item: RssItem
    @Binding var isSelected: Bool // 将 isSelected 改为绑定变量
    @State private var isHovered: Bool = false
    @State private var isLinkHovered: Bool = false // 新增状态变量
    @Environment(\.colorScheme) var colorScheme // 获取当前的颜色模式

    var body: some View {
        HStack {
            Button(action: {
                isSelected.toggle() // 点击时切换选中状态
            }) {
                VStack(alignment: .leading, spacing: 8) { // 增加垂直间距
                    if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200) // 设置图片高度
                                .cornerRadius(8)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(nil)
                    Text(item.description)
                        .font(.subheadline)
                        .lineLimit(isSelected ? nil : 1) // 根据选中状态调整行数
                        .truncationMode(.tail)
                    Text(item.pubDate)
                        .font(.caption)
                        .foregroundColor(self.isSelected ? .white : .gray) // 选中时字体颜色��白色
                }
                .padding(.vertical)
                .padding(.horizontal, 8) // 调整左右内边距为8px
                .foregroundColor(isSelected ? .white : (colorScheme == .dark ? .white : .black)) // 选中时字体颜色为白色
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(self.isSelected ? Color.blue : (isHovered ? Color.gray.opacity(0.2) : Color.clear)) // 选中时背景色为蓝色
                )
                .onHover { hovering in
                    isHovered = hovering
                }
            }
            .buttonStyle(PlainButtonStyle()) // 确保按钮样式不影响布局
            .contentShape(Rectangle()) // 确保整个区域都可以点击

            Image(systemName: "link")
                .foregroundColor(.blue)
                .padding(.trailing, 8)
                .onTapGesture {
                    if let url = URL(string: item.link) {
                        NSWorkspace.shared.open(url) // 使用默认浏览器打开链接
                    }
                }
                .onHover { hovering in
                    isLinkHovered = hovering
                    NSCursor.pointingHand.set() // 设置鼠标指针为手形
                }
        }
    }
}

// MARK: - Modern RSS Item View
struct ModernRssItemView: View {
    let item: RssItem
    let isSelected: Bool
    let onTap: () -> Void
    let onLinkTap: () -> Void
    
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ModernCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Image Section
                if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(DesignSystem.Colors.backgroundSecondary)
                            .frame(height: 180)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    }
                    .cornerRadius(DesignSystem.CornerRadius.md, corners: [.topLeft, .topRight])
                }
                
                // Content Section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    // Title
                    Text(item.title)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(isSelected ? nil : 2)
                        .multilineTextAlignment(.leading)
                    
                    // Description
                    Text(item.description)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(isSelected ? nil : 3)
                        .multilineTextAlignment(.leading)
                    
                    // Footer with date and actions
                    HStack {
                        // Date with icon
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Text(item.pubDate)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                        
                        Spacer()
                        
                        // Action buttons
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            // Expand/Collapse button
                            Button(action: onTap) {
                                Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .frame(width: 24, height: 24)
                                    .background(DesignSystem.Colors.primaryLight)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Link button
                            Button(action: onLinkTap) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(DesignSystem.Colors.primary)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(DesignSystem.Animation.smooth, value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Modern Settings Sheet
struct ModernSettingsSheet: View {
    @Binding var rssUrl: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var tempUrl: String = ""
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RSS 源设置")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("更换 RSS 源来获取不同的内容")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(DesignSystem.Colors.backgroundSecondary)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // URL Input
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("RSS URL")
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                TextField("输入 RSS 源地址", text: $tempUrl)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(DesignSystem.Typography.body)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .cornerRadius(DesignSystem.CornerRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(DesignSystem.Colors.cardBorder, lineWidth: 1)
                    )
            }
            
            // Preset URLs (optional)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("常用源")
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.sm) {
                    presetButton("技术资讯", "https://feeds.feedburner.com/oreilly/radar")
                    presetButton("设计灵感", "https://www.smashingmagazine.com/feed/")
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: DesignSystem.Spacing.md) {
                ModernButton("取消", style: .secondary) {
                    onCancel()
                }
                
                ModernButton("保存") {
                    rssUrl = tempUrl
                    onSave()
                }
                .disabled(tempUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(width: 480, height: 400)
        .background(DesignSystem.Colors.adaptiveBackground(colorScheme))
        .onAppear {
            tempUrl = rssUrl
        }
    }
    
    private func presetButton(_ title: String, _ url: String) -> some View {
        Button(action: {
            tempUrl = url
        }) {
            Text(title)
                .font(DesignSystem.Typography.caption)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Colors.backgroundSecondary)
                .cornerRadius(DesignSystem.CornerRadius.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
