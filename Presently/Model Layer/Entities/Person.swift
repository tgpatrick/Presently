//
//  Person.swift
//  GiftHub
//
//  Created by Thomas Patrick on 11/11/21.
//

import Foundation

struct Person: Codable, Identifiable, Hashable, Equatable {
    var id: String
    var name: String
    var setUp: Bool
    var giftHistory: [HistoricalGift]
    var exceptions: [String]
    var wishList: [WishListItem]
    var recipient: String
    var organizer: Bool
}

extension Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.name < rhs.name
    }
}
