//
//  PeopleRepository.swift
//  Presently
//
//  Created by Thomas Patrick on 8/3/23.
//

import Foundation

class PeopleRepository: Repository {
    @Published var storage: [Person]? = nil
    @Published var loadingState: LoadingState = .resting
    
    @MainActor
    func get(_ id: String) async {
        loadingState = .loading
        if let request = Requests.getAllPeople(fromExchange: id) {
            let result = await Network.load(request)
            if case let .success(success) = result {
                storage = success.Items
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
    //TODO: create an endpoint + request for an array of people
    func put(_ people: [Person]) async {
        loadingState = .loading
        for person in people {
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
    }
    
    @MainActor
    //TODO: create an endpoint for deleting all people in an exchange
    func delete(_ exchangeId: String) async {
        print("NOT YET IMPLEMENTED; please delete people individually for now")
    }
}
