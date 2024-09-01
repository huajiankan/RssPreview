//
//  RssParseDelegate.swift
//  RssPreviewer
//
//  Created by KrabsWang on 2024/9/1.
//


import Foundation

class RssParserDelegate: NSObject, XMLParserDelegate {
    var rssItems: [RssItem] = []
    var rssTitle: String = "" // 添加 RSS 标题
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDescription = ""
    private var currentPubDate = ""
    private var currentImageUrl: String? // 添加当前图片 URL
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentPubDate = ""
            currentImageUrl = nil // 重置当前图片 URL
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            if rssTitle.isEmpty {
                rssTitle = string // 设置 RSS 标题
            } else {
                currentTitle += string
            }
        case "link": currentLink += string
        case "description": currentDescription += string
        case "pubDate": currentPubDate += string
        case "media:content": // 假设图片 URL 在 media:content 标签中
            if currentImageUrl == nil {
                currentImageUrl = string
            }
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let formattedDate = formatDate(currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines))
            let item = RssItem(id: UUID(), title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                               link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                               description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                               pubDate: formattedDate,
                               imageUrl: currentImageUrl) // 添加图片 URL
            rssItems.append(item)
            print("Parsed item: \(item.title)")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z" // 原始日期格式
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 目标日期格式
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}
