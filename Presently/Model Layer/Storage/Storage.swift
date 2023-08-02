//
//  Storage.swift
//  Presently
//
//  Created by Thomas Patrick on 8/1/23.
//

import SwiftUI

@MainActor
protocol Storage {
    associatedtype DataType: Codable, Equatable
    
    static var fileName: String { get }
    var items: [DataType] { get set }
    
    static func fileURL() throws -> URL
    func load() async throws
    func save(_ item: DataType) async throws
    func delete(_ item: DataType) async throws
}

extension Storage {
    static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(fileName)
    }
}
