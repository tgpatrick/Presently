//
//  Person.swift
//  GiftHub
//
//  Created by Thomas Patrick on 11/11/21.
//

import Foundation

struct Person: Codable, Hashable, Equatable {
    var exchangeId: String
    var personId: String
    var name: String
    var greeting: String?
    var setUp: Bool
    var giftHistory: [HistoricalGift]
    var exceptions: [String]
    var wishList: [WishListItem]
    var wishesPublic: Bool
    var recipient: String
    var organizer: Bool
}

extension Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.name < rhs.name
    }
}

extension Person: Identifiable {
    var id: String {
        exchangeId + personId
    }
}
