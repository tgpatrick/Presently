//
//  LoginStorage.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

struct LoginStorageItem: Hashable, Codable, Equatable {
    var exchangeName: String
    var personName: String
    var exchangeID: String
    var personID: String
}

extension LoginStorageItem: Identifiable {
    var id: String {
        return exchangeID + personID
    }
}

@MainActor
class LoginStorage: Storage, ObservableObject {
    static var fileName: String = "logins.data"
    @Published var items = [LoginStorageItem]()
    
    func load() async throws {
        let task = Task<[LoginStorageItem], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let logins = try JSONDecoder().decode([LoginStorageItem].self, from: data)
            return logins
        }
        let logins = try await task.value
        self.items = logins
    }

    func save(_ login: LoginStorageItem) async throws {
        try await load()
        items.append(login)
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }

    func delete(_ login: LoginStorageItem) async throws {
        try await load()
        items.removeAll(where: {
            $0 == login
        })
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
