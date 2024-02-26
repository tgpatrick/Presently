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
    var succeeded: Bool { get }
    
    func get(_ id: String) async
    func put(_ : T) async
    func delete(_ id: String) async
    
    func reset()
    func manualSuccess()
    
    init()
}

extension Repository {
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
    
    func reset() {
        self.loadingState = .resting
        self.storage = nil
    }
    
    func manualSuccess() {
        self.loadingState = .success
    }
}
