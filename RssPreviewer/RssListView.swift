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
    @State private var selectedRssItem: RssItem?
    @State private var searchText: String = ""
    @State private var rssUrl: String = ""
    @State private var showSheet: Bool = false
    @State private var showErrorAlert: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack(spacing: 16) {
                Text(viewModel.rssTitle)
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { showSheet = true }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Color(colorScheme == .dark ? .black : .white)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )

            // 搜索栏
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索文章...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .imageScale(.small)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if viewModel.isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(colorScheme == .dark ? .black : .white))
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredRssItems) { item in
                            RssListItemView(item: item, isSelected: Binding(
                                get: { item == selectedRssItem },
                                set: { isSelected in
                                    withAnimation(.spring()) {
                                        selectedRssItem = isSelected ? item : nil
                                    }
                                }
                            ))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            }
        }
        .background(Color(colorScheme == .dark ? .black : .white)) // 设置背景颜色与List一致
        .onAppear {
            viewModel.fetchRssItems()
        }
        .sheet(isPresented: $showSheet) {
            VStack(spacing: 20) {
                Text("RSS 源设置")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("RSS URL")
                        .foregroundColor(.secondary)
                    TextField("输入 RSS 订阅地址", text: $rssUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(spacing: 16) {
                    Button("取消") {
                        showSheet = false
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button("确认") {
                        viewModel.rssUrl = rssUrl
                        viewModel.fetchRssItems()
                        showSheet = false
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
            .padding(24)
            .frame(width: 400)
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区域
            if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(ProgressView())
                }
            }
            
            // 内容区域
            VStack(alignment: .leading, spacing: 12) {
                Text(item.title)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(2)
                
                Text(item.description)
                    .font(.system(size: 14))
                    .lineLimit(isSelected ? nil : 3)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(item.pubDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: item.link) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                            Text("阅读原文")
                        }
                        .font(.system(size: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .opacity(isHovered ? 0.95 : 1.0)
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isSelected.toggle()
            }
        }
    }
}
