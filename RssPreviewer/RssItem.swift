import Foundation

struct RssItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let link: String
    let description: String
    let pubDate: String
    let imageUrl: String? // 添加图片 URL 属性
    
    static func == (lhs: RssItem, rhs: RssItem) -> Bool {
        return lhs.id == rhs.id
    }
}
