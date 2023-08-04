//
//  PersonRepository.swift
//  Presently
//
//  Created by Thomas Patrick on 8/3/23.
//

import Foundation

class PersonRepository: Repository {
    @Published var storage: Person? = nil
    @Published var loadingState: LoadingState = .resting
    
    @MainActor
    func get(_ id: String) async {
        loadingState = .loading
        let eid = String(id.prefix(4))
        let pid = String(id.suffix(4))
        if let request = Requests.getPerson(exchangeId: eid, personId: pid) {
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
    }
    
    @MainActor
    func put(_ person: Person) async {
        loadingState = .loading
        if let request = Requests.putPerson(person) {
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
        let eid = String(id.prefix(4))
        let pid = String(id.suffix(4))
        if let request = Requests.deletePerson(exchangeId: eid, personId: pid) {
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
