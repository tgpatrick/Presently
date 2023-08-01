//
//  PresentlyApp.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

@main
struct PresentlyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
