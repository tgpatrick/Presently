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
    var loadingState: LoadingState { get set }
    var isLoading: Bool { get }
    var succeeded: Bool { get }
    
    static func fileURL() throws -> URL
    func load() async
    func save(_ item: DataType) async
    func delete(_ item: DataType) async
}

extension Storage {
    var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }
    
    var succeeded: Bool {
        if case .success = loadingState {
            return true
        }
        return false
    }
    
    static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(fileName)
    }
}
