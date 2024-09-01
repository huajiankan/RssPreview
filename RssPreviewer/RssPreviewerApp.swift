//
//  RssPreviewerApp.swift
//  RssPreviewer
//
//  Created by KrabsWang on 2024/9/1.
//

import SwiftUI

@main
struct RssPreviewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            CommandGroup(replacing: .appInfo) {
                EmptyView()
            }
        }
    }
}
