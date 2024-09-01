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
        isLoading = true // 开始加载
        let semaphore = DispatchSemaphore(value: 0)
        
        guard let url = URL(string: rssUrl) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false // 加载结束
            }
            print("Error: Invalid URL")
            return
        }
        
        DispatchQueue.global().async {
            do {
                print("Fetching RSS data...")
                let data = try Data(contentsOf: url)
                print("RSS data fetched, size: \(data.count) bytes")
                
                let parser = XMLParser(data: data)
                let delegate = RssParserDelegate()
                parser.delegate = delegate
                
                print("Parsing RSS data...")
                if parser.parse() {
                    DispatchQueue.main.async {
                        self.rssItems = delegate.rssItems
                        self.rssTitle = delegate.rssTitle // 更新 RSS 标题
                        self.isLoading = false // 加载结束
                        print("Updated rssItems with \(self.rssItems.count) items")
                    }
                    DispatchQueue.main.async {
                        self.errorMessage = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse RSS data"
                        self.isLoading = false // 加载结束
                    }
                    print("Error: Failed to parse RSS data")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching RSS: \(error.localizedDescription)"
                    self.isLoading = false // 加载结束
                }
                print("Error fetching RSS: \(error.localizedDescription)")
            }
            semaphore.signal()
        }
        
        semaphore.wait()
    }
}
