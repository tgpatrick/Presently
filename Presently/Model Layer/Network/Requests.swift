//
//  Requests.swift
//  Presently
//
//  Created by Thomas Patrick on 8/2/23.
//

import Foundation

struct Requests {
    // MARK: Exchanges
    static func putExchange(_ exchange: Exchange) -> NetworkRequest<UnusedReponse>? {
        return .init(method: .put, path: "/exchanges", body: exchange, resultType: UnusedReponse.self)
    }
    
    static func deleteExchange(withId id: String) -> NetworkRequest<UnusedReponse>? {
        return .init(method: .delete, path: "/exchanges/\(id)", resultType: UnusedReponse.self)
    }
    
    static func getExchange(withId id: String) -> NetworkRequest<ItemResponse<Exchange>>? {
        return .init(path: "/exchanges/\(id)", resultType: ItemResponse<Exchange>.self)
    }
    
    // MARK: People
    static func putPerson(_ person: Person) -> NetworkRequest<UnusedReponse>? {
        return .init(method: .put, path: "/people", body: person, resultType: UnusedReponse.self)
    }
    
    static func deletePerson(exchangeId: String, personId: String) -> NetworkRequest<UnusedReponse>? {
        return .init(method: .delete, path: "/people/\(exchangeId)/\(personId)", resultType: UnusedReponse.self)
    }
    
    static func getPerson(exchangeId: String, personId: String) -> NetworkRequest<ItemResponse<Person>>? {
        return .init(path: "/people/\(exchangeId)/\(personId)", resultType: ItemResponse<Person>.self)
    }
    
    static func getAllPeople(fromExchange id: String) -> NetworkRequest<MultipleItemResponse<Person>>? {
        return .init(path: "people/all/\(id)", resultType: MultipleItemResponse<Person>.self)
    }
}
