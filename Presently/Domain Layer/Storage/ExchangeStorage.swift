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
    @Published var loadingState: LoadingState = .resting
    
    func load() async {
        let task = Task<[Exchange], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let exchanges = try JSONDecoder().decode([Exchange].self, from: data)
            return exchanges
        }
        do {
            let exchanges = try await task.value
            self.items = exchanges
            loadingState = .success
        } catch {
            loadingState = .error(ErrorWrapper(error: error, guidance: "We'll try to load from network"))
        }
    }
    
    func save(_ exchange: Exchange) async {
        await load()
        items.append(exchange)
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        do {
            _ = try await task.value
            loadingState = .success
        } catch {
            loadingState = .error(ErrorWrapper(error: error, guidance: "Try again later"))
        }
    }
    
    func delete(_ exchange: Exchange) async {
        await load()
        items.removeAll(where: {
            $0 == exchange
        })
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        do {
            _ = try await task.value
            loadingState = .success
        } catch {
            loadingState = .error(ErrorWrapper(error: error, guidance: "Try again later"))
        }
    }
}
