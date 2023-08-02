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
    @AppStorage("CurrentExchangeID") static var exchangeID: String?
    @AppStorage("CurrentPersonID") static var personID: String?
    
    var body: some Scene {
        WindowGroup {
            ContentView(loginStorage: loginStorage)
                .task {
                    do {
                        try await loginStorage.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }
    }
}
