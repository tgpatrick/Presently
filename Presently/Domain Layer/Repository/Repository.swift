//
//  Repository.swift
//  Presently
//
//  Created by Thomas Patrick on 8/2/23.
//

import Foundation

enum LoadingState {
    case resting
    case loading
    case success
    case error(ErrorWrapper)
}

protocol Repository: ObservableObject {
    associatedtype T
    
    var storage: T? { get set }
    var loadingState: LoadingState { get set }
    var isLoading: Bool { get }
    
    func get(_ id: String) async
    func put(_ : T) async
    func delete(_ id: String) async
}

extension Repository {
    var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }
}
