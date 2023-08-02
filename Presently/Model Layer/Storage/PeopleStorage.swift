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
    @Published var items = [Person]()
    
    func load() async throws {
        let task = Task<[Person], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let people = try JSONDecoder().decode([Person].self, from: data)
            return people
        }
        let people = try await task.value
        self.items = people
    }
    
    func save(_ person: Person) async throws {
        try await load()
        items.append(person)
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    func delete(_ person: Person) async throws {
        try await load()
        items.removeAll(where: {
            $0 == person
        })
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
