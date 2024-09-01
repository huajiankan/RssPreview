//
//  RssViewModel.swift
//  RssPreviewer
//
//  Created by KrabsWang on 2024/9/1.
//

import Foundation
import Combine

@MainActor
class RssViewModel: ObservableObject {
    @Published var rssItems: [RssItem] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true // 添加加载状态
    @Published var selectedRssItem: RssItem? // 添加选中的 RSS 项目
    @Published var rssUrl: String = "https://baoyu.io/feed.xml" // 添加 RSS URL
    @Published var rssTitle: String = "" // 添加 RSS 标题

    func fetchRssItems() {
        isLoading = true
        errorMessage = nil // 重置错误消息
        
        guard let url = URL(string: rssUrl) else {
            errorMessage = "无效的 URL"
            isLoading = false
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let parser = XMLParser(data: data)
                let delegate = RssParserDelegate()
                parser.delegate = delegate
                
                if parser.parse() {
                    self.rssItems = delegate.rssItems
                    self.rssTitle = delegate.rssTitle
                } else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "解析 RSS 数据失败"])
                }
            } catch {
                errorMessage = "获取 RSS 失败: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
}
