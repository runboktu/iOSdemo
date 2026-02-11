//
//  iosDemoApp.swift
//  iosDemo
//
//  Created by mingshu on 2026/2/11.
//

import SwiftUI

@main
struct iosDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
