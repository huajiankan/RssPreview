import SwiftUI

struct ContentView: View {
    var body: some View {
        RssListView(viewModel: RssViewModel())
            .onAppear {
                if let window = NSApplication.shared.windows.first {
                    window.setContentSize(NSSize(width: 600, height: 800)) // 设置窗口大小
                    window.center() // 居中显示
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
