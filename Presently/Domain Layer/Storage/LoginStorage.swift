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
    @Published var loadingState: LoadingState = .resting
    
    func load() async {
        let task = Task<[LoginStorageItem], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let logins = try JSONDecoder().decode([LoginStorageItem].self, from: data)
            return logins
        }
        do {
            let logins = try await task.value
            self.items = logins
            loadingState = .success
        } catch {
            loadingState = .error(ErrorWrapper(error: error, guidance: "You'll have to login again"))
        }
    }

    func save(_ login: LoginStorageItem) async {
        await load()
        items.append(login)
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

    func delete(_ login: LoginStorageItem) async {
        await load()
        items.removeAll(where: {
            $0 == login
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
