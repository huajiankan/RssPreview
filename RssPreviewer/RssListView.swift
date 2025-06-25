//
//  RssListView.swift
//  RssPreviewer
//
//  Created by KrabsWang on 2024/9/1.
//

import Foundation
import SwiftUI

struct RssListView: View {
    @ObservedObject var viewModel: RssViewModel
    @State private var selectedRssItem: RssItem? // 新增选中状态变量
    @State private var searchText: String = "" // 新增搜索文本状态变量
    @State private var rssUrl: String = "" // 新增 RSS URL 状态变量
    @State private var showSheet: Bool = false // 控制弹窗显示
    @State private var showErrorAlert: Bool = false // 新增错误提示状态
    @State private var isSettingsHovered: Bool = false // 设置按钮悬停状态
    @Environment(\.colorScheme) var colorScheme // 获取当前的颜色模式

    var body: some View {
        VStack(spacing: 0) {
            // 现代化的导航栏
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(viewModel.rssTitle.isEmpty ? "RSS 阅读器" : viewModel.rssTitle)
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .lineLimit(2)
                        
                        if !viewModel.rssTitle.isEmpty {
                            Text("保持更新，掌握最新资讯")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 现代化的设置按钮
                    Button(action: {
                        showSheet = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isSettingsHovered ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(isSettingsHovered ? DesignSystem.Colors.hover : Color.clear)
                            )
                            .scaleEffect(isSettingsHovered ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isSettingsHovered)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { hovering in
                        isSettingsHovered = hovering
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.lg)

                // 现代化的搜索框
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("搜索文章标题...", text: $searchText)
                        .font(DesignSystem.Typography.body)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                searchText = ""
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
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .fill(DesignSystem.Colors.backgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                .stroke(DesignSystem.Colors.borderLight, lineWidth: 1)
                        )
                )
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .padding(.bottom, DesignSystem.Spacing.md)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignSystem.Colors.backgroundPrimary,
                        DesignSystem.Colors.backgroundPrimary.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // 内容区域
            if viewModel.isLoading {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
                    
                    Text("正在加载精彩内容...")
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DesignSystem.Colors.backgroundPrimary)
            } else {
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(filteredRssItems) { item in
                            RssListItemView(item: item, isSelected: Binding(
                                get: { item == selectedRssItem },
                                set: { isSelected in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if isSelected {
                                            selectedRssItem = item
                                        } else {
                                            selectedRssItem = nil
                                        }
                                    }
                                }
                            ))
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .background(DesignSystem.Colors.backgroundPrimary)
            }
        }
        .background(DesignSystem.Colors.backgroundPrimary)
        .onAppear {
            viewModel.fetchRssItems()
        }
        .sheet(isPresented: $showSheet) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // 标题区域
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    Text("更换 RSS 源")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("输入新的 RSS 链接来获取不同的内容")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, DesignSystem.Spacing.lg)
                
                // 输入框区域
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("RSS URL")
                        .font(DesignSystem.Typography.callout.weight(.medium))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    TextField("https://example.com/rss.xml", text: $rssUrl)
                        .font(DesignSystem.Typography.body)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .fill(DesignSystem.Colors.backgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                
                Spacer()
                
                // 按钮区域
                HStack(spacing: DesignSystem.Spacing.md) {
                    Button("取消") {
                        showSheet = false
                        rssUrl = ""
                    }
                    .secondaryButtonStyle()
                    
                    Button("确认更换") {
                        viewModel.rssUrl = rssUrl
                        viewModel.fetchRssItems()
                        showSheet = false
                        rssUrl = ""
                    }
                    .primaryButtonStyle()
                    .disabled(rssUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.bottom, DesignSystem.Spacing.lg)
            }
            .frame(width: 400, height: 280)
            .background(DesignSystem.Colors.backgroundPrimary)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("错误"),
                message: Text(viewModel.errorMessage ?? "未知错误"),
                dismissButton: .default(Text("确定"))
            )
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            if newValue != nil {
                showErrorAlert = true
            }
        }
    }

    var filteredRssItems: [RssItem] {
        if searchText.isEmpty {
            return viewModel.rssItems
        } else {
            return viewModel.rssItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct RssListItemView: View {
    let item: RssItem
    @Binding var isSelected: Bool
    @State private var isHovered: Bool = false
    @State private var isLinkHovered: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 主内容区域
            Button(action: {
                isSelected.toggle()
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // 图片区域
                    if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
                        } placeholder: {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .fill(DesignSystem.Colors.backgroundSecondary)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(0.8)
                                )
                        }
                    } else {
                        // 默认图标
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "doc.text")
                                    .font(.system(size: 24))
                                    .foregroundColor(DesignSystem.Colors.primary)
                            )
                    }
                    
                    // 文本内容
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(item.title)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(isSelected ? DesignSystem.Colors.selectedText : DesignSystem.Colors.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(item.description)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(isSelected ? DesignSystem.Colors.selectedText.opacity(0.8) : DesignSystem.Colors.textSecondary)
                            .lineLimit(isSelected ? nil : 2)
                            .multilineTextAlignment(.leading)
                            .animation(.easeInOut(duration: 0.3), value: isSelected)
                        
                        Spacer()
                        
                        Text(item.pubDate)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(isSelected ? DesignSystem.Colors.selectedText.opacity(0.7) : DesignSystem.Colors.textTertiary)
                    }
                    
                    Spacer()
                }
                .padding(DesignSystem.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .fill(
                            isSelected ? DesignSystem.Colors.selected :
                            (isHovered ? DesignSystem.Colors.hover : DesignSystem.Colors.backgroundCard)
                        )
                        .shadow(
                            color: isSelected ? DesignSystem.Colors.selected.opacity(0.3) : DesignSystem.Shadow.small.color,
                            radius: isSelected ? 8 : DesignSystem.Shadow.small.radius,
                            x: DesignSystem.Shadow.small.x,
                            y: isSelected ? 4 : DesignSystem.Shadow.small.y
                        )
                )
                .scaleEffect(isSelected ? 1.02 : (isHovered ? 1.01 : 1.0))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
                .onHover { hovering in
                    isHovered = hovering
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            
            // 链接按钮
            Button(action: {
                if let url = URL(string: item.link) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isLinkHovered ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                            .fill(isLinkHovered ? DesignSystem.Colors.primary.opacity(0.1) : Color.clear)
                    )
                    .scaleEffect(isLinkHovered ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isLinkHovered)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                isLinkHovered = hovering
            }
        }
    }
}
