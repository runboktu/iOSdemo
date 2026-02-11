//
//  ContentView.swift
//  iosDemo
//
//  旧的ContentView - 现在重定向到新的AppRoot
//  注意：这个文件保留是为了向后兼容，实际入口是AppRoot.swift
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // 重定向到AppRoot
        // AppRoot在iosDemoApp.swift中被使用
        AppRoot()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
