//
//  ExchangeStorage.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

@MainActor
class ExchangeStorage: Storage, ObservableObject {
    static var fileName: String = "exchanges.data"
    @Published var items = [Exchange]()
    
    func load() async throws {
        let task = Task<[Exchange], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let exchanges = try JSONDecoder().decode([Exchange].self, from: data)
            return exchanges
        }
        let exchanges = try await task.value
        self.items = exchanges
    }
    
    func save(_ exchange: Exchange) async throws {
        try await load()
        items.append(exchange)
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    func delete(_ exchange: Exchange) async throws {
        try await load()
        items.removeAll(where: {
            $0 == exchange
        })
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
