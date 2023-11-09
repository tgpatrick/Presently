//
//  PeopleStorage.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

@MainActor
class PeopleStorage: Storage, ObservableObject {
    static var fileName: String = "people.data"
    @Published var items = People()
    @Published var loadingState: LoadingState = .resting
    
    func load() async {
        let task = Task<People, Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let people = try JSONDecoder().decode(People.self, from: data)
            return people
        }
        do {
            let people = try await task.value
            self.items = people
            loadingState = .success
        } catch {
            loadingState = .error(ErrorWrapper(error: error, guidance: "We'll try to load from network"))
        }
    }
    
    func save(_ person: Person) async {
        await load()
        items.append(person)
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
    
    func delete(_ person: Person) async {
        await load()
        items.removeAll(where: {
            $0 == person
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
