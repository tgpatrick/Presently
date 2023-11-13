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
        if let exchange = testExchanges.first(where: { $0.id == id }) {
            storage = exchange
            loadingState = .success
        } else {
            loadingState = .error(ErrorWrapper(error: NetworkError.serverError(code: 404, url: ""), guidance: "Please try again"))
        }
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
        #if targetEnvironment(simulator)
        self.loadingState = .success
        #else
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
        #endif
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
