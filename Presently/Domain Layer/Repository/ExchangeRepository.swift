//
//  ExchangeRepository.swift
//  Presently
//
//  Created by Thomas Patrick on 8/3/23.
//

import Foundation

class ExchangeRepository: Repository {
    @Published var storage: Exchange? = nil
    @Published var loadingState: LoadingState = .resting
    
    @MainActor
    func get(_ id: String) async {
        loadingState = .loading
        #if targetEnvironment(simulator)
        storage = testExchange
        loadingState = .success
        #else
        if let request = Requests.getExchange(withId: id) {
            let result = await Network.load(request)
            if case let .success(success) = result {
                storage = success.Item
                loadingState = .success
            } else if case let .failure(error) = result {
                print(error)
                loadingState = .error(ErrorWrapper(error: error, guidance: "Please try again"))
            }
        } else {
            loadingState = .error(ErrorWrapper(error: NetworkError.request, guidance: "Please file a bug report"))
        }
        #endif
    }
    
    @MainActor
    func put(_ exchange: Exchange) async {
        loadingState = .loading
        if let request = Requests.putExchange(exchange) {
            let result = await Network.load(request)
            if case .success = result {
                loadingState = .success
            } else if case let .failure(error) = result {
                print(error)
                loadingState = .error(ErrorWrapper(error: error, guidance: "Please try again"))
            }
        } else {
            loadingState = .error(ErrorWrapper(error: NetworkError.request, guidance: "Please file a bug report"))
        }
    }
    
    @MainActor
    func delete(_ id: String) async {
        loadingState = .loading
        if let request = Requests.deleteExchange(withId: id) {
            let result = await Network.load(request)
            if case .success = result {
                loadingState = .success
            } else if case let .failure(error) = result {
                print(error)
                loadingState = .error(ErrorWrapper(error: error, guidance: "Please try again"))
            }
        } else {
            loadingState = .error(ErrorWrapper(error: NetworkError.request, guidance: "Please file a bug report"))
        }
    }
}
