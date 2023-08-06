//
//  PresentlyApp.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

@main
struct PresentlyApp: App {
    @StateObject var loginStorage = LoginStorage()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginStorage)
                .task {
                    await loginStorage.load()
                }
        }
    }
}
