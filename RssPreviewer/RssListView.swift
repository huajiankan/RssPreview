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
    @Environment(\.colorScheme) var colorScheme // 获取当前的颜色模式

    var body: some View {
        VStack {
            HStack {
                Text(viewModel.rssTitle) // 显示当前 RSS 标题
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.leading, 10)
                    .padding(.top, 10)
                Spacer()
                Text("⚙️") // 使用设置的 emoji 图标
                    .font(.largeTitle)
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                    .onTapGesture {
                        showSheet = true
                    }
            }
            .padding(.horizontal, 8) // 设置左右间距为8px

            HStack {
                TextField("你可以通过标题过滤内容，快试试吧！", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 10)
                    .frame(height: 40) // 设置搜索栏高度
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 10)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 8) // 设置左右间距为8px

            if viewModel.isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(colorScheme == .dark ? .black : .white))
                    .foregroundColor(.gray)
            } else {
                List(filteredRssItems) { item in
                    RssListItemView(item: item, isSelected: Binding(
                        get: { item == selectedRssItem },
                        set: { isSelected in
                            if isSelected {
                                selectedRssItem = item
                            } else {
                                selectedRssItem = nil
                            }
                        }
                    ))
                    .listRowInsets(EdgeInsets()) // 移除默认的行内边距
                    .listRowBackground(Color.clear) // 确保背景颜色透明
                }
                .background(Color(colorScheme == .dark ? .black : .white)) // 设置List的背景颜色
                .padding(.horizontal, 5) // 添加水平内边距，确保左右留白5px
            }
        }
        .background(Color(colorScheme == .dark ? .black : .white)) // 设置背景颜色与List一致
        .onAppear {
            viewModel.fetchRssItems()
        }
        .sheet(isPresented: $showSheet) {
            VStack(alignment: .leading) {
                Text("换个源试试？")
                    .font(.headline)
                    .padding()
                TextField("输入 RSS URL", text: $rssUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Spacer() // 添加 Spacer 以将按钮推到最底部
                HStack {
                    Spacer()
                    Button("取消") {
                        showSheet = false
                    }
                    .padding(.trailing)
                    Button("确认") {
                        viewModel.rssUrl = rssUrl
                        viewModel.fetchRssItems()
                        showSheet = false
                    }
                    .padding(.trailing)
                }
                .padding(.bottom) // 调整按钮与底部的间距
            }
            .frame(width: 300, height: 150) // 调整弹窗的高度
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
                        .foregroundColor(self.isSelected ? .white : .gray) // 选中时字体颜色为白色
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
